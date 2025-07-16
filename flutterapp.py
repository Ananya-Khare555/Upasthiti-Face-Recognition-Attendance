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

if _name_ == "_main_":
    import uvicorn
    uvicorn.run(app, host="192.168.63.151", port=8000)
