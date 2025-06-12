from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from PIL import Image
import torch
import torchvision.transforms as transforms
import io

app = FastAPI()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# تحميل النموذج المحفوظ بصيغة TorchScript
MODEL_PATH = r"c:\Users\LENOVO LOQ\glaucoma_detaction_fainal\best_model.pt"

model = torch.jit.load(MODEL_PATH, map_location=torch.device("cpu"))
model.to(device)
model.eval()

# تحويلات الصورة كما تم التدريب عليها
transform = transforms.Compose([
    transforms.Grayscale(num_output_channels=3),   # إن كانت الصور رمادية
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225])
])
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    print(f"headers: {file.content_type}, filename: {file.filename}")

    try:
        print(f"📥 Received file: {file.filename}")

        # اقرأ البيانات مرة واحدة
        contents = await file.read()

        # حاول تحويل البيانات إلى صورة
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        img_tensor = transform(image).unsqueeze(0).to(device)

        with torch.no_grad():
            output = model(img_tensor)
            prob = torch.softmax(output, dim=1)
            predicted_class = torch.argmax(prob, dim=1).item()
            confidence = prob[0][predicted_class].item()

        label = "glaucoma" if predicted_class == 1 else "normal"

        return JSONResponse(content={
            "result": label,
            "confidence": round(confidence, 4),
            "status": "success"
        })

    except Exception as e:
        print(f"❌ Error: {e}")
        return JSONResponse(
            content={"status": "error", "message": f"Failed to process image: {str(e)}"},
            status_code=400
        )
