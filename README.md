# 👥 Face Recognition Attendance System

📌 A Python-based system for automated attendance using face recognition.

## ✨ Key Features
- 👁️ Face detection with MTCNN  
- 🧠 Face embedding generation using InceptionResnetV1  
- 🔌 REST API built with FastAPI  
- 🗃️ MongoDB for data storage  

## ⚙️ Tech Stack
- 🐍 Python 3.8+  
- 🔥 PyTorch (for face recognition)  
- 🚀 FastAPI (backend)  
- 🍃 MongoDB (database)  
- 📷 OpenCV (image processing)  

## 📦 Installation
1. Clone the repository:
```bash
git clone https://github.com/Ananya-Khare555/Upasthiti-Face-Recognition-Attendance.git
cd Upasthiti-Face-Recognition-Attendance
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Configure MongoDB:
```python
# In config.py
MONGODB_URI = "mongodb://localhost:27017"
```

## 🔧 Usage
Start the API server:
```bash
uvicorn main:app --reload
```

### API Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/register` | POST | Register new users |
| `/attendance` | POST | Mark attendance |
| `/users` | GET | List registered users |

## 🏗️ Project Structure
```
.
├── main.py             # FastAPI application
├── face_recognition.py # ML models
├── database.py         # MongoDB operations
├── config.py           # Configuration
├── requirements.txt    # Dependencies
└── README.md
```

## 👩💻 Contributor
- [Ananya Khare](https://github.com/Ananya-Khare555)

## 📜 License
MIT
```