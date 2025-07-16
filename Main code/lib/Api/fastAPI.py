# from fastapi import FastAPI, File, UploadFile, Form, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# import cv2
# import numpy as np
# import torch
# from facenet_pytorch import MTCNN, InceptionResnetV1
# import pickle
# from datetime import datetime
# import os
# from typing import Dict, List
# import json
# from pathlib import Path

# app = FastAPI()

# # CORS configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Configuration - Using proper path handling
# BASE_DIR = Path(__file__).parent
# EMBEDDING_PATH = BASE_DIR / "face_embeddings.pkl"
# ATTENDANCE_FILE = BASE_DIR / "attendance_records.json"
# FACES_DIR = BASE_DIR / "faces"

# # Create directories if they don't exist
# FACES_DIR.mkdir(exist_ok=True)

# # Initialize models
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
# resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# # Load data
# def load_embeddings():
#     try:
#         if EMBEDDING_PATH.exists():
#             with open(EMBEDDING_PATH, 'rb') as f:
#                 return pickle.load(f)
#     except Exception as e:
#         print(f"Error loading embeddings: {e}")
#     return {}

# def load_attendance():
#     try:
#         if ATTENDANCE_FILE.exists():
#             with open(ATTENDANCE_FILE, 'r') as f:
#                 return json.load(f)
#     except Exception as e:
#         print(f"Error loading attendance: {e}")
#     return []

# #driver code
# db = load_embeddings()
# attendance_records = load_attendance()

# @app.post("/register")
# async def register_face(name: str = Form(...), image: UploadFile = File(...)):
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         raise HTTPException(status_code=400, detail="No face detected")
    
#     embedding = resnet(faces[0].unsqueeze(0).to(device)).detach().cpu()
#     db[name] = embedding
    
#     # Save embeddings
#     with open(EMBEDDING_PATH, 'wb') as f:
#         pickle.dump(db, f)
    
#     # Save sample image
#     cv2.imwrite(str(FACES_DIR / f"{name}.jpg"), cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
    
#     return {"status": "success", "message": f"{name} registered successfully"}

# @app.post("/recognize")
# async def recognize_face(image: UploadFile = File(...)):
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         return {"status": "error", "message": "No faces detected"}
    
#     current_embeddings = resnet(faces.to(device)).detach().cpu()
#     names = list(db.keys())
#     embeddings = torch.stack(list(db.values())).squeeze(1)
    
#     results = []
#     for i, emb in enumerate(current_embeddings):
#         dists = torch.norm(embeddings - emb, dim=1)
#         min_dist, idx = torch.min(dists, dim=0)
        
#         if min_dist < 0.7:
#             name = names[idx]
#             results.append({
#                 "name": name,
#                 "confidence": float(1 - min_dist),
#                 "status": "recognized"
#             })
#         else:
#             results.append({
#                 "name": "Unknown",
#                 "confidence": 0.0,
#                 "status": "unknown"
#             })
    
#     return {"status": "success", "results": results}

# @app.post("/mark_attendance")
# async def mark_attendance(data: dict):
#     name = data.get("name")
#     if not name:
#         raise HTTPException(status_code=400, detail="Name is required")
    
#     timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
#     # Find or create today's record
#     today = datetime.now().strftime("%Y-%m-%d")
#     record = next((r for r in attendance_records if r["date"] == today), None)
    
#     if not record:
#         record = {
#             "date": today,
#             "present": [],
#             "absent": list(db.keys())
#         }
#         attendance_records.append(record)
    
#     if name not in record["present"]:
#         record["present"].append(name)
#         if name in record["absent"]:
#             record["absent"].remove(name)
        
#         # Save attendance
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f, indent=4)
        
#         return {"status": "success", "message": f"{name} marked present"}
    
#     return {"status": "info", "message": f"{name} already marked"}

# @app.get("/attendance")
# async def get_attendance():
#     return {"status": "success", "data": attendance_records}

# @app.get("/students")
# async def get_students():
#     return {"status": "success", "data": list(db.keys())}

# @app.delete("/students/{student_name}")
# async def delete_student(student_name: str):
#     global db, attendance_records
    
#     if student_name not in db:
#         raise HTTPException(status_code=404, detail="Student not found")
    
#     try:
#         # Remove student from database
#         del db[student_name]
        
#         # Save updated embeddings
#         with open(EMBEDDING_PATH, 'wb') as f:
#             pickle.dump(db, f)
        
#         # Delete student's face image if exists
#         face_image = FACES_DIR / f"{student_name}.jpg"
#         if face_image.exists():
#             face_image.unlink()
        
#         # Update attendance records
#         updated_records = []
#         for record in attendance_records:
#             # Create new present/absent lists without the student
#             present = [name for name in record['present'] if name != student_name]
#             absent = [name for name in record['absent'] if name != student_name]
            
#             # Only keep records that still have students
#             if present or absent:
#                 updated_records.append({
#                     "date": record["date"],
#                     "present": present,
#                     "absent": absent
#                 })
        
#         attendance_records = updated_records
        
#         # Save updated attendance
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f, indent=4)
        
#         return {"status": "success", "message": f"Student {student_name} deleted successfully"}
    
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error deleting student: {str(e)}")

# @app.delete("/reset-all")
# async def reset_all_data():
#     global db, attendance_records
    
#     try:
#         # Reset face embeddings
#         db = {}
#         with open(EMBEDDING_PATH, 'wb') as f:
#             pickle.dump(db, f)
        
#         # Reset attendance records
#         attendance_records = []
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f)
        
#         # Delete all face images
#         for file_path in FACES_DIR.glob("*"):
#             try:
#                 if file_path.is_file():
#                     file_path.unlink()
#             except Exception as e:
#                 print(f"Error deleting {file_path}: {e}")
        
#         return {"status": "success", "message": "All data reset successfully"}
    
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error resetting data: {str(e)}")

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="192.168.31.229", port=8000)






# from fastapi import FastAPI, File, UploadFile, Form, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# import cv2
# import numpy as np
# import torch
# from facenet_pytorch import MTCNN, InceptionResnetV1
# import pickle
# from datetime import datetime
# import os
# from typing import Dict, List
# import json
# from pathlib import Path

# app = FastAPI()

# # CORS configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Configuration - Using proper path handling
# BASE_DIR = Path(__file__).parent
# EMBEDDING_PATH = BASE_DIR / "face_embeddings.pkl"
# ATTENDANCE_FILE = BASE_DIR / "attendance_records.json"
# FACES_DIR = BASE_DIR / "faces"

# # Create directories if they don't exist
# FACES_DIR.mkdir(exist_ok=True)

# # Initialize models
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
# resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# # Load data
# def load_embeddings():
#     try:
#         if EMBEDDING_PATH.exists():
#             with open(EMBEDDING_PATH, 'rb') as f:
#                 return pickle.load(f)
#     except Exception as e:
#         print(f"Error loading embeddings: {e}")
#     return {}

# def load_attendance():
#     try:
#         if ATTENDANCE_FILE.exists():
#             with open(ATTENDANCE_FILE, 'r') as f:
#                 return json.load(f)
#     except Exception as e:
#         print(f"Error loading attendance: {e}")
#     return []

# # Initialize databases
# db = load_embeddings()
# attendance_records = load_attendance()

# @app.post("/register")
# async def register_face(name: str = Form(...), image: UploadFile = File(...)):
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         raise HTTPException(status_code=400, detail="No face detected")
    
#     embedding = resnet(faces[0].unsqueeze(0).to(device)).detach().cpu()
#     db[name] = embedding
    
#     # Save embeddings
#     with open(EMBEDDING_PATH, 'wb') as f:
#         pickle.dump(db, f)
    
#     # Save sample image
#     cv2.imwrite(str(FACES_DIR / f"{name}.jpg"), cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
    
#     return {"status": "success", "message": f"{name} registered successfully"}

# @app.post("/recognize")
# async def recognize_face(image: UploadFile = File(...)):
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         return {"status": "error", "message": "No faces detected"}
    
#     current_embeddings = resnet(faces.to(device)).detach().cpu()
#     names = list(db.keys())
#     embeddings = torch.stack(list(db.values())).squeeze(1)
    
#     results = []
#     for i, emb in enumerate(current_embeddings):
#         dists = torch.norm(embeddings - emb, dim=1)
#         min_dist, idx = torch.min(dists, dim=0)
        
#         if min_dist < 0.7:
#             name = names[idx]
#             results.append({
#                 "name": name,
#                 "confidence": float(1 - min_dist),
#                 "status": "recognized",
#                 "position": {  # Adding position information for bounding boxes
#                     "left": 0.3,  # These should be calculated from face detection
#                     "top": 0.3,   # Replace with actual coordinates from MTCNN
#                     "width": 0.4,
#                     "height": 0.4
#                 }
#             })
#         else:
#             results.append({
#                 "name": "Unknown",
#                 "confidence": 0.0,
#                 "status": "unknown",
#                 "position": {
#                     "left": 0.3,
#                     "top": 0.3,
#                     "width": 0.4,
#                     "height": 0.4
#                 }
#             })
    
#     return {"status": "success", "results": results}

# @app.post("/mark_attendance")
# async def mark_attendance(data: dict):
#     name = data.get("name")
#     session_time_str = data.get("session_time")
    
#     if not name:
#         raise HTTPException(status_code=400, detail="Name is required")
    
#     try:
#         session_time = datetime.fromisoformat(session_time_str) if session_time_str else datetime.now()
#     except ValueError:
#         session_time = datetime.now()
    
#     timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
#     # Create a unique session ID based on date and hour-minute
#     session_id = f"{session_time.date()}_{session_time.hour}_{session_time.minute}"
    
#     # Find or create session record
#     session_record = next((r for r in attendance_records if r.get("session_id") == session_id), None)
    
#     if not session_record:
#         session_record = {
#             "session_id": session_id,
#             "date": session_time.strftime("%Y-%m-%d"),
#             "start_time": session_time.strftime("%H:%M"),
#             "present": [],
#             "absent": list(db.keys())
#         }
#         attendance_records.append(session_record)
    
#     if name not in session_record["present"]:
#         session_record["present"].append(name)
#         if name in session_record["absent"]:
#             session_record["absent"].remove(name)
        
#         # Save attendance
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f, indent=4)
        
#         return {"status": "success", "message": f"{name} marked present at {timestamp}"}
    
#     return {"status": "info", "message": f"{name} already marked in this session"}

# # Existing APIs remain unchanged below this point
# @app.get("/attendance")
# async def get_attendance():
#     return {"status": "success", "data": attendance_records}

# @app.get("/students")
# async def get_students():
#     return {"status": "success", "data": list(db.keys())}

# @app.delete("/students/{student_name}")
# async def delete_student(student_name: str):
#     global db, attendance_records
    
#     if student_name not in db:
#         raise HTTPException(status_code=404, detail="Student not found")
    
#     try:
#         # Remove student from database
#         del db[student_name]
        
#         # Save updated embeddings
#         with open(EMBEDDING_PATH, 'wb') as f:
#             pickle.dump(db, f)
        
#         # Delete student's face image if exists
#         face_image = FACES_DIR / f"{student_name}.jpg"
#         if face_image.exists():
#             face_image.unlink()
        
#         # Update attendance records
#         updated_records = []
#         for record in attendance_records:
#             # Create new present/absent lists without the student
#             present = [name for name in record.get('present', []) if name != student_name]
#             absent = [name for name in record.get('absent', []) if name != student_name]
            
#             # Only keep records that still have students
#             if present or absent:
#                 updated_record = {
#                     "date": record["date"],
#                     "present": present,
#                     "absent": absent
#                 }
#                 if "session_id" in record:
#                     updated_record["session_id"] = record["session_id"]
#                     updated_record["start_time"] = record["start_time"]
#                 updated_records.append(updated_record)
        
#         attendance_records = updated_records
        
#         # Save updated attendance
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f, indent=4)
        
#         return {"status": "success", "message": f"Student {student_name} deleted successfully"}
    
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error deleting student: {str(e)}")

# @app.delete("/reset-all")
# async def reset_all_data():
#     global db, attendance_records
    
#     try:
#         # Reset face embeddings
#         db = {}
#         with open(EMBEDDING_PATH, 'wb') as f:
#             pickle.dump(db, f)
        
#         # Reset attendance records
#         attendance_records = []
#         with open(ATTENDANCE_FILE, 'w') as f:
#             json.dump(attendance_records, f)
        
#         # Delete all face images
#         for file_path in FACES_DIR.glob("*"):
#             try:
#                 if file_path.is_file():
#                     file_path.unlink()
#             except Exception as e:
#                 print(f"Error deleting {file_path}: {e}")
        
#         return {"status": "success", "message": "All data reset successfully"}
    
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error resetting data: {str(e)}")

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="192.168.75.151", port=8000)












# from fastapi import FastAPI, File, UploadFile, Form, HTTPException, Depends
# from fastapi.middleware.cors import CORSMiddleware
# from fastapi.security import APIKeyHeader
# import cv2
# import numpy as np
# import torch
# from facenet_pytorch import MTCNN, InceptionResnetV1
# from pymongo import MongoClient
# from bson.binary import Binary
# import pickle
# from datetime import datetime
# from typing import Dict, List, Optional
# from bson import ObjectId
# import json
# from pydantic import BaseModel
# from enum import Enum

# app = FastAPI()

# # CORS configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )


# # MongoDB configuration
# MONGODB_URI = "mongodb://localhost:27017/"
# DATABASE_NAME = "hierarchical_attendance_system"
# client = MongoClient(MONGODB_URI)
# db = client[DATABASE_NAME]

# # Initialize models
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
# resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# # Models
# class School(BaseModel):
#     name: str
#     address: str
#     contact: str

# class Course(BaseModel):
#     name: str  # e.g., "BTech", "MTech"
#     duration_years: int

# class Year(BaseModel):
#     year_number: int  # 1, 2, 3, etc.
#     subjects: List[str]

# class Section(BaseModel):
#     name: str  # e.g., "A", "B"
#     class_teacher: str

# class Student(BaseModel):
#     roll_no: str
#     name: str
#     email: Optional[str] = None
#     phone: Optional[str] = None
#     address: Optional[str] = None

# class AttendanceStatus(str, Enum):
#     PRESENT = "P"
#     ABSENT = "A"
#     LATE = "L"
#     HOLIDAY = "H"

# class AttendanceRecord(BaseModel):
#     date: str
#     time: str
#     subject: str
#     attendance: Dict[str, AttendanceStatus]  # student_id -> status

# class Subject(BaseModel):
#     name: str
#     code: str
#     teacher: str

# # Helper functions
# def get_school_collection(school_name: str):
#     return db[school_name]


# # --------------------------
# # Original Endpoints (Maintained for backward compatibility)
# # --------------------------

# @app.post("/register")
# async def register_face(name: str = Form(...), image: UploadFile = File(...)):
#     """Original register endpoint now registers to default school"""
#     return await register_student(
#         school_name="default",
#         course_name="default",
#         year_number=1,
#         section_name="A",
#         student=Student(roll_no=name, name=name),
#         image=image
#     )

# @app.post("/recognize")
# async def recognize_face(image: UploadFile = File(...)):
#     """Original recognize endpoint searches across all schools"""
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         return {"status": "error", "message": "No faces detected"}
    
#     # Get all students from all schools
#     all_students = []
#     for school_name in db.list_collection_names():
#         if school_name not in ["system.indexes"]:
#             school_db = db[school_name]
#             for student in school_db["students"].find({"embedding": {"$exists": True}}):
#                 all_students.append({
#                     "embedding": pickle.loads(student["embedding"]),
#                     "info": {
#                         "name": student["name"],
#                         "roll_no": student["roll_no"],
#                         "school": school_name,
#                         "course": student.get("course", ""),
#                         "year": student.get("year", ""),
#                         "section": student.get("section", "")
#                     }
#                 })
    
#     if not all_students:
#         return {"status": "error", "message": "No registered students found"}
    
#     # Prepare embeddings
#     embeddings = torch.stack([s["embedding"] for s in all_students]).squeeze(1)
#     current_embeddings = resnet(faces.to(device)).detach().cpu()
    
#     results = []
#     for i, emb in enumerate(current_embeddings):
#         dists = torch.norm(embeddings - emb, dim=1)
#         min_dist, idx = torch.min(dists, dim=0)
        
#         if min_dist < 0.7:
#             student = all_students[idx]["info"]
#             results.append({
#                 "name": student["name"],
#                 "roll_no": student["roll_no"],
#                 "confidence": float(1 - min_dist),
#                 "status": "recognized",
#                 "school": student["school"],
#                 "course": student["course"],
#                 "year": student["year"],
#                 "section": student["section"],
#                 "position": {
#                     "left": 0.3,
#                     "top": 0.3,
#                     "width": 0.4,
#                     "height": 0.4
#                 }
#             })
#         else:
#             results.append({
#                 "name": "Unknown",
#                 "confidence": 0.0,
#                 "status": "unknown",
#                 "position": {
#                     "left": 0.3,
#                     "top": 0.3,
#                     "width": 0.4,
#                     "height": 0.4
#                 }
#             })
    
#     return {"status": "success", "results": results}

# @app.post("/mark_attendance")
# async def mark_attendance(data: dict):
#     """Original mark_attendance endpoint works with default school"""
#     name = data.get("name")
#     session_time_str = data.get("session_time")
    
#     if not name:
#         raise HTTPException(status_code=400, detail="Name is required")
    
#     try:
#         session_time = datetime.fromisoformat(session_time_str) if session_time_str else datetime.now()
#     except ValueError:
#         session_time = datetime.now()
    
#     timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#     session_id = f"{session_time.date()}_{session_time.hour}_{session_time.minute}"
    
#     # Find student across all schools
#     student = None
#     for school_name in db.list_collection_names():
#         if school_name not in ["system.indexes"]:
#             school_db = db[school_name]
#             student = school_db["students"].find_one({"name": name})
#             if student:
#                 break
    
#     if not student:
#         raise HTTPException(status_code=404, detail="Student not found")
    
#     # Find or create session record
#     school_db = db[student["school"]]
#     session_record = school_db["attendance"].find_one({"session_id": session_id})
    
#     if not session_record:
#         # Get all students in the same section
#         section_students = list(school_db["students"].find({
#             "course": student["course"],
#             "year": student["year"],
#             "section": student["section"]
#         }))
        
#         session_record = {
#             "session_id": session_id,
#             "school": student["school"],
#             "course": student["course"],
#             "year": student["year"],
#             "section": student["section"],
#             "date": session_time.strftime("%Y-%m-%d"),
#             "start_time": session_time.strftime("%H:%M"),
#             "present": [],
#             "absent": [s["name"] for s in section_students]
#         }
#         school_db["attendance"].insert_one(session_record)
    
#     if name not in session_record["present"]:
#         school_db["attendance"].update_one(
#             {"_id": session_record["_id"]},
#             {
#                 "$addToSet": {"present": name},
#                 "$pull": {"absent": name}
#             }
#         )
#         return {"status": "success", "message": f"{name} marked present at {timestamp}"}
    
#     return {"status": "info", "message": f"{name} already marked in this session"}

# @app.get("/attendance")
# async def get_attendance():
#     """Original attendance endpoint returns all attendance records"""
#     all_records = []
#     for school_name in db.list_collection_names():
#         if school_name not in ["system.indexes"]:
#             records = list(db[school_name]["attendance"].find({}, {'_id': 0}))
#             all_records.extend(records)
#     return {"status": "success", "data": all_records}

# @app.get("/students")
# async def get_students():
#     """Original students endpoint returns all students"""
#     all_students = []
#     for school_name in db.list_collection_names():
#         if school_name not in ["system.indexes"]:
#             students = list(db[school_name]["students"].find({}, {'_id': 0, 'embedding': 0}))
#             all_students.extend(students)
#     return {"status": "success", "data": all_students}

# @app.delete("/students/{student_name}")
# async def delete_student(student_name: str):
#     """Original delete endpoint searches across all schools"""
#     deleted = False
#     for school_name in db.list_collection_names():
#         if school_name not in ["system.indexes"]:
#             school_db = db[school_name]
#             student = school_db["students"].find_one({"name": student_name})
#             if student:
#                 # Delete student
#                 school_db["students"].delete_one({"name": student_name})
                
#                 # Delete face image if exists
#                 school_db["face_images"].delete_one({"name": student_name})
                
#                 # Update attendance records
#                 school_db["attendance"].update_many(
#                     {},
#                     {
#                         "$pull": {
#                             "present": student_name,
#                             "absent": student_name
#                         }
#                     }
#                 )
                
#                 deleted = True
#                 break
    
#     if not deleted:
#         raise HTTPException(status_code=404, detail="Student not found")
    
#     return {"status": "success", "message": f"Student {student_name} deleted successfully"}

# @app.delete("/reset-all")
# async def reset_all_data():
#     """Original reset endpoint clears all data"""
#     for collection_name in db.list_collection_names():
#         db[collection_name].drop()
#     return {"status": "success", "message": "All data reset successfully"}

# # --------------------------
# # New Hierarchical Endpoints
# # --------------------------

# @app.post("/schools/")
# async def create_school(school: School):
#     if school.name in db.list_collection_names():
#         raise HTTPException(status_code=400, detail="School already exists")
    
#     # Create collections for the school
#     school_db = db[school.name]
#     school_db["courses"]
#     school_db["subjects"]
#     school_db["students"]
#     school_db["attendance"]
#     school_db["face_images"]
#     school_db["metadata"].insert_one(school.dict())
    
#     return {"status": "success", "message": f"School {school.name} created successfully"}

# @app.get("/schools/")
# async def list_schools():
#     return {"schools": [name for name in db.list_collection_names() if name not in ["system.indexes"]]}

# @app.post("/{school_name}/courses/")
# async def add_course(school_name: str, course: Course):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     db[school_name]["courses"].insert_one(course.dict())
#     return {"status": "success", "message": f"Course {course.name} added to {school_name}"}

# @app.get("/{school_name}/courses/")
# async def list_courses(school_name: str):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     courses = list(db[school_name]["courses"].find({}, {"_id": 0}))
#     return {"courses": courses}

# @app.post("/{school_name}/{course_name}/years/")
# async def add_year(school_name: str, course_name: str, year: Year):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     if not db[school_name]["courses"].find_one({"name": course_name}):
#         raise HTTPException(status_code=404, detail="Course not found")
    
#     db[school_name]["years"].insert_one({
#         "course": course_name,
#         **year.dict()
#     })
#     return {"status": "success", "message": f"Year {year.year_number} added to {course_name}"}

# @app.post("/{school_name}/{course_name}/{year_number}/sections/")
# async def add_section(
#     school_name: str, 
#     course_name: str, 
#     year_number: int, 
#     section: Section,
# ):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     if not db[school_name]["courses"].find_one({"name": course_name}):
#         raise HTTPException(status_code=404, detail="Course not found")
    
#     if not db[school_name]["years"].find_one({"course": course_name, "year_number": year_number}):
#         raise HTTPException(status_code=404, detail="Year not found in this course")
    
#     db[school_name]["sections"].insert_one({
#         "course": course_name,
#         "year": year_number,
#         **section.dict()
#     })
#     return {"status": "success", "message": f"Section {section.name} added to year {year_number}"}

# @app.post("/{school_name}/{course_name}/{year_number}/{section_name}/students/")
# async def register_student(
#     school_name: str,
#     course_name: str,
#     year_number: int,
#     section_name: str,
#     student: Student,
#     image: UploadFile = File(...),
# ):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     # Verify course, year, and section exist
#     if not db[school_name]["courses"].find_one({"name": course_name}):
#         raise HTTPException(status_code=404, detail="Course not found")
    
#     if not db[school_name]["years"].find_one({"course": course_name, "year_number": year_number}):
#         raise HTTPException(status_code=404, detail="Year not found in this course")
    
#     if not db[school_name]["sections"].find_one({"course": course_name, "year": year_number, "name": section_name}):
#         raise HTTPException(status_code=404, detail="Section not found")
    
#     # Process image
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         raise HTTPException(status_code=400, detail="No face detected")
    
#     embedding = resnet(faces[0].unsqueeze(0).to(device)).detach().cpu()
    
#     # Create student record
#     student_data = {
#         **student.dict(),
#         "school": school_name,
#         "course": course_name,
#         "year": year_number,
#         "section": section_name,
#         "embedding": Binary(pickle.dumps(embedding)),
#         "registration_date": datetime.now().isoformat()
#     }
    
#     # Store student
#     db[school_name]["students"].insert_one(student_data)
    
#     # Store face image
#     _, img_encoded = cv2.imencode('.jpg', cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
#     db[school_name]["face_images"].insert_one({
#         "student_id": student.roll_no,
#         "name": student.name,
#         "image": Binary(img_encoded.tobytes()),
#         "school": school_name,
#         "course": course_name,
#         "year": year_number,
#         "section": section_name
#     })
    
#     return {"status": "success", "message": f"Student {student.name} registered successfully"}

# @app.post("/{school_name}/{course_name}/{year_number}/{section_name}/take-attendance")
# async def hierarchical_mark_attendance(
#     school_name: str,
#     course_name: str,
#     year_number: int,
#     section_name: str,
#     subject: str = Form(...),
#     image: UploadFile = File(...),
# ):
#     if school_name not in db.list_collection_names():
#         raise HTTPException(status_code=404, detail="School not found")
    
#     # Get all students in this section with embeddings
#     students = list(db[school_name]["students"].find({
#         "course": course_name,
#         "year": year_number,
#         "section": section_name,
#         "embedding": {"$exists": True}
#     }))
    
#     if not students:
#         raise HTTPException(status_code=400, detail="No students with face embeddings in this section")
    
#     # Prepare known embeddings
#     known_embeddings = []
#     student_info = []
#     for student in students:
#         known_embeddings.append(pickle.loads(student["embedding"]))
#         student_info.append({
#             "roll_no": student["roll_no"],
#             "name": student["name"]
#         })
    
#     known_embeddings = torch.stack(known_embeddings).squeeze(1)
    
#     # Process the uploaded image
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     # Detect faces
#     faces = mtcnn(img)
#     if faces is None:
#         return {"status": "error", "message": "No faces detected in the image"}
    
#     # Get embeddings for detected faces
#     current_embeddings = resnet(faces.to(device)).detach().cpu()
    
#     # Create attendance record
#     now = datetime.now()
#     session_id = f"{now.date()}_{now.hour}_{now.minute}"
#     attendance_record = {
#         "session_id": session_id,
#         "school": school_name,
#         "course": course_name,
#         "year": year_number,
#         "section": section_name,
#         "subject": subject,
#         "date": now.strftime("%Y-%m-%d"),
#         "time": now.strftime("%H:%M"),
#         "present": [],
#         "absent": [s["name"] for s in students]
#     }
    
#     # Match faces with known students
#     recognized_students = []
#     for emb in current_embeddings:
#         dists = torch.norm(known_embeddings - emb, dim=1)
#         min_dist, idx = torch.min(dists, dim=0)
        
#         if min_dist < 0.7:  # Recognition threshold
#             recognized_student = student_info[idx]
#             attendance_record["present"].append(recognized_student["name"])
#             if recognized_student["name"] in attendance_record["absent"]:
#                 attendance_record["absent"].remove(recognized_student["name"])
#             recognized_students.append(recognized_student["name"])
    
#     # Store attendance record
#     db[school_name]["attendance"].insert_one(attendance_record)
    
#     return {
#         "status": "success",
#         "recognized_students": recognized_students,
#         "attendance_record": {
#             "session_id": attendance_record["session_id"],
#             "date": attendance_record["date"],
#             "time": attendance_record["time"],
#             "present": attendance_record["present"],
#             "absent": attendance_record["absent"]
#         }
#     }

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="192.168.63.151", port=8000)




# Trial 3.
# from fastapi import FastAPI, File, UploadFile, Form, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# import cv2
# import numpy as np
# import torch
# from facenet_pytorch import MTCNN, InceptionResnetV1
# from pymongo import MongoClient
# from bson.binary import Binary
# import pickle
# from datetime import datetime
# from typing import Dict, List, Optional
# from bson import ObjectId
# from pydantic import BaseModel, Field
# import uuid

# app = FastAPI()

# # CORS configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # MongoDB configuration
# MONGODB_URI = "mongodb://localhost:27017/"
# DATABASE_NAME = "attendance_system_v2"
# client = MongoClient(MONGODB_URI)
# db = client[DATABASE_NAME]

# # Initialize models
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
# resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# # Models with UUID fields
# class School(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     name: str
#     address: str
#     created_at: datetime = Field(default_factory=datetime.now)

# class Course(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     school_id: str
#     name: str
#     duration_years: int
#     created_at: datetime = Field(default_factory=datetime.now)

# class Year(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     course_id: str
#     year_name:str # B.Tech(22-26)
#     sections: List[str] = []
#     created_at: datetime = Field(default_factory=datetime.now)

# class Section(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     year_id: str
#     course_id:str
#     name: str
#     class_teacher: str
#     created_at: datetime = Field(default_factory=datetime.now)

# class Student(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     section_id: str
#     section_name:str
#     course_name:str
#     course_id:str
#     year:int
#     year_id:str
#     roll_no: str
#     dob:str
#     name: str
#     email: Optional[str] = None
#     phone: Optional[str] = None
#     address: Optional[str] = None
#     created_at: datetime = Field(default_factory=datetime.now)

# class AttendanceRecord(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     course_id:str
#     year_id:str
#     section_id:str
#     subject_id:str
#     subject: str
#     date: str
#     time: str
#     attendance_students: List[str] = []  # List of student IDs ] -> ["13","14","53","10"]
#     attendance_report: List[str] = []   # List of student attendance -> ["A","P","A","A"]
#     created_at: datetime = Field(default_factory=datetime.now)

# # # Helper functions
# def get_collection(name: str):
#     return db[name]

# def validate_references(ref_type: str, ref_id: str):
#     """Validate that a reference ID exists in its collection"""
#     collection_map = {
#         'school': 'schools',
#         'course': 'courses',
#         'year': 'years',
#         'section': 'sections',
#         'student': 'students'
#     }
    
#     if ref_type not in collection_map:
#         raise ValueError(f"Invalid reference type: {ref_type}")
    
#     if not db[collection_map[ref_type]].find_one({"id": ref_id}):
#         raise HTTPException(status_code=404, detail=f"{ref_type.capitalize()} not found")

# # --------------------------
# # School Endpoints
# # --------------------------

# @app.post("/schools/")
# async def create_school(school: School):
#     schools = get_collection("schools")
    
#     # Check if school name already exists
#     if schools.find_one({"name": school.name}):
#         raise HTTPException(status_code=400, detail="School with this name already exists")
    
#     school_dict = school.dict()
#     schools.insert_one(school_dict)
    
#     return {
#         "status": "success",
#         "school_id": school.id,
#         "message": f"School {school.name} created successfully"
#     }

# @app.get("/schools/")
# async def list_schools():
#     schools = list(get_collection("schools").find({}, {"_id": 0}))
#     return {"status": "success", "schools": schools}

# # --------------------------
# # Course Endpoints
# # --------------------------

# @app.post("/courses/")
# async def create_course(course: Course):
#     courses = get_collection("courses")
    
#     # Validate school exists
#     validate_references('school', course.school_id)
    
#     # Check if course name exists in this school
#     if courses.find_one({"school_id": course.school_id, "name": course.name}):
#         raise HTTPException(status_code=400, detail="Course with this name already exists in this school")
    
#     course_dict = course.dict()
#     courses.insert_one(course_dict)
    
#     return {
#         "status": "success", 
#         "course_id": course.id,
#         "message": f"Course {course.name} created successfully"
#     }

# @app.get("/schools/{school_id}/courses")
# async def get_courses_by_school(school_id: str):
#     validate_references('school', school_id)
    
#     courses = list(get_collection("courses").find(
#         {"school_id": school_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "courses": courses}

# # --------------------------
# # Year Endpoints
# # --------------------------

# @app.post("/years/")
# async def create_year(year: Year):
#     years = get_collection("years")
    
#     # Validate course exists
#     validate_references('course', year.course_id)
    
#     # Check if year number exists in this course
#     if years.find_one({"course_id": year.course_id, "year_number": year.year_number}):
#         raise HTTPException(status_code=400, detail="Year with this number already exists in this course")
    
#     year_dict = year.dict()
#     years.insert_one(year_dict)
    
#     return {
#         "status": "success",
#         "year_id": year.id,
#         "message": f"Year {year.year_number} created successfully"
#     }

# @app.get("/courses/{course_id}/years")
# async def get_years_by_course(course_id: str):
#     validate_references('course', course_id)
    
#     years = list(get_collection("years").find(
#         {"course_id": course_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "years": years}

# # --------------------------
# # Section Endpoints
# # --------------------------

# @app.post("/sections/")
# async def create_section(section: Section):
#     sections = get_collection("sections")
    
#     # Validate year exists
#     validate_references('year', section.year_id)
    
#     # Check if section name exists in this year
#     if sections.find_one({"year_id": section.year_id, "name": section.name}):
#         raise HTTPException(status_code=400, detail="Section with this name already exists in this year")
    
#     section_dict = section.dict()
#     sections.insert_one(section_dict)
    
#     return {
#         "status": "success",
#         "section_id": section.id,
#         "message": f"Section {section.name} created successfully"
#     }

# @app.get("/years/{year_id}/sections")
# async def get_sections_by_year(year_id: str):
#     validate_references('year', year_id)
    
#     sections = list(get_collection("sections").find(
#         {"year_id": year_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "sections": sections}

# # --------------------------
# # Student Endpoints
# # --------------------------

# @app.post("/students/")
# async def register_student(
#     student: Student,
#     image: UploadFile = File(...)
# ):
#     students = get_collection("students")
    
#     # Validate section exists
#     validate_references('section', student.section_id)
    
#     # Check if roll number exists in this section
#     if students.find_one({"section_id": student.section_id, "roll_no": student.roll_no}):
#         raise HTTPException(status_code=400, detail="Student with this roll number already exists in this section")
    
#     # Process image and create embedding
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         raise HTTPException(status_code=400, detail="No face detected in the image")
    
#     embedding = resnet(faces[0].unsqueeze(0).to(device)).detach().cpu()
    
#     # Create student record
#     student_dict = student.dict()
#     student_dict["embedding"] = Binary(pickle.dumps(embedding))
    
#     # Store student
#     students.insert_one(student_dict)
    
#     # Store face image
#     _, img_encoded = cv2.imencode('.jpg', cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
#     get_collection("face_images").insert_one({
#         "student_id": student.id,
#         "image": Binary(img_encoded.tobytes()),
#         "created_at": datetime.now()
#     })
    
#     return {
#         "status": "success",
#         "student_id": student.id,
#         "message": f"Student {student.name} registered successfully"
#     }

# @app.get("/sections/{section_id}/students")
# async def get_students_by_section(section_id: str):
#     validate_references('section', section_id)
    
#     students = list(get_collection("students").find(
#         {"section_id": section_id},
#         {"_id": 0, "embedding": 0}  # Exclude embedding for listing
#     ))
#     return {"status": "success", "students": students}

# # --------------------------
# # Attendance Endpoints
# # --------------------------

# @app.post("/attendance/")
# async def mark_attendance(
#     section_id: str,
#     subject: str = Form(...),
#     image: UploadFile = File(...)
# ):
#     # Validate section exists
#     validate_references('section', section_id)
    
#     # Get all students in this section with embeddings
#     students = list(get_collection("students").find(
#         {"section_id": section_id, "embedding": {"$exists": True}}
#     ))
    
#     if not students:
#         raise HTTPException(status_code=400, detail="No students with face embeddings in this section")
    
#     # Prepare known embeddings and student info
#     student_embeddings = []
#     student_info = []
#     for student in students:
#         student_embeddings.append(pickle.loads(student["embedding"]))
#         student_info.append({
#             "id": student["id"],
#             "name": student["name"],
#             "roll_no": student["roll_no"]
#         })
    
#     embeddings = torch.stack(student_embeddings).squeeze(1)
    
#     # Process the uploaded image
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     # Detect faces
#     faces = mtcnn(img)
#     if faces is None:
#         return {"status": "error", "message": "No faces detected in the image"}
    
#     # Get embeddings for detected faces
#     current_embeddings = resnet(faces.to(device)).detach().cpu()
    
#     # Create attendance record
#     now = datetime.now()
#     attendance_record = {
#         "id": str(uuid.uuid4()),
#         "section_id": section_id,
#         "subject": subject,
#         "date": now.strftime("%Y-%m-%d"),
#         "time": now.strftime("%H:%M"),
#         "present_students": [],
#         "absent_students": [s["id"] for s in student_info],
#         "created_at": now
#     }
    
#     # Match faces with known students
#     recognized_students = []
#     for emb in current_embeddings:
#         dists = torch.norm(embeddings - emb, dim=1)
#         min_dist, idx = torch.min(dists, dim=0)
        
#         if min_dist < 0.7:  # Recognition threshold
#             student = student_info[idx]
#             attendance_record["present_students"].append(student["id"])
#             if student["id"] in attendance_record["absent_students"]:
#                 attendance_record["absent_students"].remove(student["id"])
#             recognized_students.append(student)
    
#     # Store attendance record
#     get_collection("attendance").insert_one(attendance_record)
    
#     return {
#         "status": "success",
#         "attendance_id": attendance_record["id"],
#         "recognized_students": recognized_students,
#         "message": "Attendance marked successfully"
#     }

# @app.get("/sections/{section_id}/attendance")
# async def get_attendance_by_section(section_id: str):
#     validate_references('section', section_id)
    
#     attendance_records = list(get_collection("attendance").find(
#         {"section_id": section_id},
#         {"_id": 0}
#     ))
#     return {"status": "success", "attendance_records": attendance_records}

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="192.168.63.151", port=8000)



# from fastapi import FastAPI, File, UploadFile, Form, HTTPException
# from fastapi.middleware.cors import CORSMiddleware
# import cv2
# import numpy as np
# import torch
# from facenet_pytorch import MTCNN, InceptionResnetV1
# from pymongo import MongoClient
# from bson.binary import Binary
# import pickle
# from datetime import datetime
# from typing import Dict, List, Optional
# from bson import ObjectId
# from pydantic import BaseModel, Field
# import uuid

# app = FastAPI()

# # CORS configuration
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # MongoDB configuration
# MONGODB_URI = "mongodb://localhost:27017/"
# DATABASE_NAME = "attendance_system_v2"
# client = MongoClient(MONGODB_URI)
# db = client[DATABASE_NAME]

# # Initialize models
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
# resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)

# # Models with UUID fields
# class School(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     name: str
#     address: str
#     created_at: datetime = Field(default_factory=datetime.now)

# class Course(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     school_id: str
#     name: str
#     duration_years: int
#     created_at: datetime = Field(default_factory=datetime.now)

# class Year(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     course_id: str
#     year_name: str  #"1"
#     sections: List[str] = []
#     created_at: datetime = Field(default_factory=datetime.now)

# class Section(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     year_id: str
#     course_id:str
#     name: str
#     class_teacher: str
#     created_at: datetime = Field(default_factory=datetime.now)

# class Student(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     section_id: str
#     section_name:str
#     course_name:str
#     course_id:str
#     year: str
#     year_id:str
#     roll_no: str
#     dob:str
#     name: str
#     email: Optional[str] = None
#     phone: Optional[str] = None
#     address: Optional[str] = None
#     created_at: datetime = Field(default_factory=datetime.now)

# class AttendanceRecord(BaseModel):
#     id: str = Field(default_factory=lambda: str(uuid.uuid4()))
#     course_id:str
#     year_id:str
#     section_id:str
#     subject_id:str
#     subject: str
#     date: str
#     time: str
#     attendance_students: List[str] = []  # List of student IDs ] -> ["13","14","53","10"]
#     attendance_report: List[str] = []   # List of student attendance -> ["A","P","A","A"]
#     created_at: datetime = Field(default_factory=datetime.now)


# # Helper functions
# def get_collection(name: str):
#     return db[name]

# def validate_references(ref_type: str, ref_id: str):
#     """Validate that a reference ID exists in its collection"""
#     collection_map = {
#         'school': 'schools',
#         'course': 'courses',
#         'year': 'years',
#         'section': 'sections',
#         'student': 'students'
#     }
    
#     if ref_type not in collection_map:
#         raise ValueError(f"Invalid reference type: {ref_type}")
    
#     if not db[collection_map[ref_type]].find_one({"id": ref_id}):
#         raise HTTPException(status_code=404, detail=f"{ref_type.capitalize()} not found")

# # --------------------------
# # School Endpoints
# # --------------------------

# @app.post("/schools/")
# async def create_school(school: School):
#     schools = get_collection("schools")
    
#     if schools.find_one({"name": school.name}):
#         raise HTTPException(status_code=400, detail="School with this name already exists")
    
#     school_dict = school.dict()
#     schools.insert_one(school_dict)
    
#     return {
#         "status": "success",
#         "school_id": school.id,
#         "message": f"School {school.name} created successfully"
#     }

# @app.get("/schools/")
# async def list_schools():
#     schools = list(get_collection("schools").find({}, {"_id": 0}))
#     return {"status": "success", "schools": schools}

# # --------------------------
# # Course Endpoints
# # --------------------------

# @app.post("/courses/")
# async def create_course(course: Course):
#     courses = get_collection("courses")
    
#     validate_references('school', course.school_id)
    
#     if courses.find_one({"school_id": course.school_id, "name": course.name}):
#         raise HTTPException(status_code=400, detail="Course with this name already exists in this school")
    
#     course_dict = course.dict()
#     courses.insert_one(course_dict)
    
#     return {
#         "status": "success", 
#         "course_id": course.id,
#         "message": f"Course {course.name} created successfully"
#     }

# @app.get("/schools/{school_id}/courses")
# async def get_courses_by_school(school_id: str):
#     validate_references('school', school_id)
    
#     courses = list(get_collection("courses").find(
#         {"school_id": school_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "courses": courses}

# # --------------------------
# # Year Endpoints
# # --------------------------

# @app.post("/years/")
# async def create_year(year: Year):
#     years = get_collection("years")
    
#     validate_references('course', year.course_id)
    
#     if years.find_one({"course_id": year.course_id, "year_name": year.year_name}):
#         raise HTTPException(status_code=400, detail="Year with this name already exists in this course")
    
#     year_dict = year.dict()
#     years.insert_one(year_dict)
    
#     return {
#         "status": "success",
#         "year_id": year.id,
#         "message": f"Year {year.year_name} created successfully"
#     }

# @app.get("/courses/{course_id}/years")
# async def get_years_by_course(course_id: str):
#     validate_references('course', course_id)
    
#     years = list(get_collection("years").find(
#         {"course_id": course_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "years": years}

# # --------------------------
# # Section Endpoints
# # --------------------------

# @app.post("/sections/")
# async def create_section(section: Section):
#     sections = get_collection("sections")
    
#     validate_references('year', section.year_id)
#     validate_references('course', section.course_id)
    
#     if sections.find_one({"year_id": section.year_id, "name": section.name}):
#         raise HTTPException(status_code=400, detail="Section with this name already exists in this year")
    
#     section_dict = section.dict()
#     sections.insert_one(section_dict)
    
#     return {
#         "status": "success",
#         "section_id": section.id,
#         "message": f"Section {section.name} created successfully"
#     }

# @app.get("/years/{year_id}/sections")
# async def get_sections_by_year(year_id: str):
#     validate_references('year', year_id)
    
#     sections = list(get_collection("sections").find(
#         {"year_id": year_id}, 
#         {"_id": 0}
#     ))
#     return {"status": "success", "sections": sections}

# # --------------------------
# # Student Endpoints
# # --------------------------

# @app.post("/students/")
# async def register_student(
#     student: Student,
#     image: UploadFile = File(...)
# ):
#     students = get_collection("students")
    
#     validate_references('section', student.section_id)
#     validate_references('course', student.course_id)
#     validate_references('year', student.year_id)
    
#     if students.find_one({"section_id": student.section_id, "roll_no": student.roll_no}):
#         raise HTTPException(status_code=400, detail="Student with this roll number already exists in this section")
    
#     # Process image and create embedding
#     contents = await image.read()
#     img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
#     img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
#     faces = mtcnn(img)
#     if faces is None:
#         raise HTTPException(status_code=400, detail="No face detected in the image")
    
#     embedding = resnet(faces[0].unsqueeze(0).to(device)).detach().cpu()
    
#     # Create student record
#     student_dict = student.dict()
#     student_dict["embedding"] = Binary(pickle.dumps(embedding))
    
#     # Store student
#     students.insert_one(student_dict)
    
#     # Store face image
#     _, img_encoded = cv2.imencode('.jpg', cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
#     get_collection("face_images").insert_one({
#         "student_id": student.id,
#         "image": Binary(img_encoded.tobytes()),
#         "created_at": datetime.now()
#     })
    
#     # Update embeddings mapping (using student_id instead of name)
#     embeddings_col = get_collection("embeddings")
#     embeddings_col.update_one(
#         {"student_id": student.id},
#         {"$set": {
#             "student_id": student.id,
#             "embedding": Binary(pickle.dumps(embedding)),
#             "updated_at": datetime.now()
#         }},
#         upsert=True
#     )
    
#     return {
#         "status": "success",
#         "student_id": student.id,
#         "message": f"Student {student.name} registered successfully"
#     }

# @app.get("/sections/{section_id}/students")
# async def get_students_by_section(section_id: str):
#     validate_references('section', section_id)
    
#     students = list(get_collection("students").find(
#         {"section_id": section_id},
#         {"_id": 0, "embedding": 0}  # Exclude embedding for listing
#     ))
#     return {"status": "success", "students": students}

# @app.get("/get_student_for_attendance")
# async def get_student_for_attendance(course_id: str, year_id: str, section_id: str):
#     validate_references('course', course_id)
#     validate_references('year', year_id)
#     validate_references('section', section_id)
    
#     students = list(get_collection("students").find(
#         {
#             "course_id": course_id,
#             "year_id": year_id,
#             "section_id": section_id
#         },
#         {"_id": 0, "embedding": 0}  # Exclude sensitive/irrelevant fields
#     ))
    
#     if not students:
#         raise HTTPException(status_code=404, detail="No students found for the given criteria")
    
#     return {
#         "status": "success",
#         "count": len(students),
#         "students": students
#     }

# # --------------------------
# # Attendance Endpoints
# # --------------------------

# @app.get("/attendance/{section_id}")
# async def get_attendance_by_section(section_id: str):
#     validate_references('section', section_id)
    
#     attendance_records = list(get_collection("attendance").find(
#         {"section_id": section_id},
#         {"_id": 0}
#     ))
#     return {"status": "success", "attendance_records": attendance_records}

# # --------------------------
# # Dummy Data Endpoints
# # --------------------------

# @app.post("/create_dummy_data/")
# async def create_dummy_data():
#     try:
#         # Create a school
#         school = School(
#             name="Dummy University",
#             address="123 Education St, Knowledge City"
#         )
#         school_dict = school.dict()
#         db.schools.insert_one(school_dict)
        
#         # Create a course
#         course = Course(
#             school_id=school.id,
#             name="Bachelor of Technology",
#             duration_years=4
#         )
#         course_dict = course.dict()
#         db.courses.insert_one(course_dict)
        
#         # Create a year
#         year = Year(
#             course_id=course.id,
#             year_name="B.Tech(22-26)"
#         )
#         year_dict = year.dict()
#         db.years.insert_one(year_dict)
        
#         # Create a section
#         section = Section(
#             year_id=year.id,
#             course_id=course.id,
#             name="A",
#             class_teacher="Dr. Smith"
#         )
#         section_dict = section.dict()
#         db.sections.insert_one(section_dict)
        
#         # Create some dummy students
#         dummy_students = [
#             {
#                 "section_id": section.id,
#                 "section_name": section.name,
#                 "course_name": course.name,
#                 "course_id": course.id,
#                 "year": 1,
#                 "year_id": year.id,
#                 "roll_no": "22BTCS001",
#                 "dob": "2000-01-01",
#                 "name": "John Doe",
#                 "email": "john@example.com",
#                 "phone": "1234567890"
#             },
#             {
#                 "section_id": section.id,
#                 "section_name": section.name,
#                 "course_name": course.name,
#                 "course_id": course.id,
#                 "year": 1,
#                 "year_id": year.id,
#                 "roll_no": "22BTCS002",
#                 "dob": "2000-02-02",
#                 "name": "Jane Smith",
#                 "email": "jane@example.com",
#                 "phone": "9876543210"
#             }
#         ]
        
#         for student_data in dummy_students:
#             student = Student(**student_data)
#             db.students.insert_one(student.dict())
        
#         return {
#             "status": "success",
#             "message": "Dummy data created successfully",
#             "school_id": school.id,
#             "course_id": course.id,
#             "year_id": year.id,
#             "section_id": section.id
#         }
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(app, host="192.168.63.151", port=8000)










from fastapi import FastAPI, File, UploadFile, Form, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
import cv2
import numpy as np
import torch
from facenet_pytorch import MTCNN, InceptionResnetV1
from pymongo import MongoClient
from gridfs import GridFS
from bson import ObjectId
from bson.binary import Binary
from datetime import datetime
from typing import Dict, List, Optional
from pydantic import BaseModel, Field
import uuid
import io

app = FastAPI(title="Smart Attendance System", version="2.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB configuration
MONGODB_URI = "mongodb://localhost:27017/"
DATABASE_NAME = "attendance_system_v2"
client = MongoClient(MONGODB_URI)
db = client[DATABASE_NAME]
fs = GridFS(db)

# Initialize models
device = 'cuda' if torch.cuda.is_available() else 'cpu'
mtcnn = MTCNN(image_size=160, margin=20, min_face_size=40, device=device, keep_all=True)
resnet = InceptionResnetV1(pretrained='vggface2').eval().to(device)


# --- Pydantic Models ---
class SchoolBase(BaseModel):
    name: str = Field(..., min_length=3)
    address: str
    established_year: int

class SchoolCreate(SchoolBase):
    pass

class School(SchoolBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class CourseBase(BaseModel):
    name: str
    description: Optional[str]
    duration_years: int = Field(..., ge=1)

class CourseCreate(CourseBase):
    school_id: str

class Course(CourseBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    school_id: str
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class YearBase(BaseModel):
    year_number: int = Field(..., ge=1, le=10)
    academic_year: str  # e.g., "2023-2024"

class YearCreate(YearBase):
    course_id: str

class Year(YearBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    course_id: str
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class SectionBase(BaseModel):
    name: str
    class_teacher: str

class SectionCreate(SectionBase):
    year_id: str

class Section(SectionBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    year_id: str
    course_id: str
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class StudentBase(BaseModel):
    full_name: str
    roll_number: str
    date_of_birth: str
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None

class StudentCreate(StudentBase):
    section_id: str

class Student(StudentBase):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    section_id: str
    course_id: str
    school_id: str
    embedding: List[float]
    image_id: str
    created_at: datetime = Field(default_factory=datetime.now)
    updated_at: datetime = Field(default_factory=datetime.now)

class AttendanceRecord(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    section_id: str
    subject: str
    date: datetime
    present_students: List[str]
    absent_students: List[str]
    created_at: datetime = Field(default_factory=datetime.now)

# --- Helper Functions ---
def get_collection(name: str):
    return db[name]

def validate_reference(collection: str, document_id: str):
    if not db[collection].find_one({"id": document_id}):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"{collection.capitalize()} not found"
        )

# --- Image Processing ---
async def process_image(image: UploadFile):
    contents = await image.read()
    img = cv2.imdecode(np.frombuffer(contents, np.uint8), cv2.IMREAD_COLOR)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    return img

async def generate_embedding(image: np.ndarray):
    faces = mtcnn(image)
    if faces is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No face detected in image"
        )
    
    with torch.no_grad():
        embedding = resnet(faces[0].unsqueeze(0).to(device))
    
    return embedding.cpu().numpy().flatten().tolist()

# --- API Endpoints ---
# School Management
@app.post("/schools/", status_code=status.HTTP_201_CREATED)
async def create_school(school: SchoolCreate):
    validate_reference("schools", school.id)
    school_data = School(**school.dict()).dict()
    db.schools.insert_one(school_data)
    return {"message": "School created successfully", "school_id": school_data["id"]}

# Course Management
@app.post("/courses/", status_code=status.HTTP_201_CREATED)
async def create_course(course: CourseCreate):
    validate_reference("schools", course.school_id)
    course_data = Course(**course.dict()).dict()
    db.courses.insert_one(course_data)
    return {"message": "Course created successfully", "course_id": course_data["id"]}

# Year Management
@app.post("/years/", status_code=status.HTTP_201_CREATED)
async def create_year(year: YearCreate):
    validate_reference("courses", year.course_id)
    year_data = Year(**year.dict()).dict()
    db.years.insert_one(year_data)
    return {"message": "Academic year created successfully", "year_id": year_data["id"]}

# Section Management
@app.post("/sections/", status_code=status.HTTP_201_CREATED)
async def create_section(section: SectionCreate):
    validate_reference("years", section.year_id)
    section_data = Section(**section.dict()).dict()
    db.sections.insert_one(section_data)
    return {"message": "Section created successfully", "section_id": section_data["id"]}

# First fix the student creation endpoint
@app.post("/sections/{section_id}/students", status_code=status.HTTP_201_CREATED)
async def create_student(
    section_id: str,
    full_name: str = Form(...),
    roll_number: str = Form(...),
    date_of_birth: str = Form(...),
    email: Optional[str] = Form(None),
    phone: Optional[str] = Form(None),
    address: Optional[str] = Form(None),
    image: UploadFile = File(...)
):
    # Validate references
    validate_reference("sections", section_id)
    section = db.sections.find_one({"id": section_id})
    course_id = section["course_id"]
    school_id = db.courses.find_one({"id": course_id})["school_id"]

    # Process image
    img = await process_image(image)
    embedding = await generate_embedding(img)
    
    # Store image in GridFS
    _, img_encoded = cv2.imencode('.jpg', cv2.cvtColor(img, cv2.COLOR_RGB2BGR))
    image_id = fs.put(img_encoded.tobytes(), filename=image.filename)

    # Create student record
    student = Student(
        full_name=full_name,
        roll_number=roll_number,
        date_of_birth=date_of_birth,
        email=email,
        phone=phone,
        address=address,
        section_id=section_id,
        course_id=course_id,
        school_id=school_id,
        embedding=embedding,
        image_id=str(image_id)
    )
    
    db.students.insert_one(student.dict())
    
    return {
        "message": "Student registered successfully",
        "student_id": student.id
    }

@app.get("/sections/{section_id}/students")
async def get_students(section_id: str):
    validate_reference("sections", section_id)
    students = list(db.students.find({"section_id": section_id}, {"_id": 0}))
    return {"count": len(students), "students": students}

@app.get("/students/{student_id}/image")
async def get_student_image(student_id: str):
    validate_reference("students", student_id)
    student = db.students.find_one({"id": student_id})
    
    try:
        grid_out = fs.get(ObjectId(student["image_id"]))
    except:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Student image not found"
        )
    
    return StreamingResponse(
        io.BytesIO(grid_out.read()),
        media_type="image/jpeg",
        headers={"Content-Disposition": f"inline; filename={grid_out.filename}"}
    )

# Attendance Management
@app.post("/sections/{section_id}/attendance")
async def record_attendance(section_id: str, record: AttendanceRecord):
    validate_reference("sections", section_id)
    record_data = record.dict()
    db.attendance.insert_one(record_data)
    return {"message": "Attendance recorded successfully"}

# --- Hierarchy Endpoints ---
@app.get("/schools/{school_id}/courses")
async def get_school_courses(school_id: str):
    validate_reference("schools", school_id)
    courses = list(db.courses.find({"school_id": school_id}, {"_id": 0}))
    return {"count": len(courses), "courses": courses}

@app.get("/courses/{course_id}/years")
async def get_course_years(course_id: str):
    validate_reference("courses", course_id)
    years = list(db.years.find({"course_id": course_id}, {"_id": 0}))
    return {"count": len(years), "years": years}

@app.get("/years/{year_id}/sections")
async def get_year_sections(year_id: str):
    validate_reference("years", year_id)
    sections = list(db.sections.find({"year_id": year_id}, {"_id": 0}))
    return {"count": len(sections), "sections": sections}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="192.168.63.151", port=8000)