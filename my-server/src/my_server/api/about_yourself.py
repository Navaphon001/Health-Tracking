from fastapi import APIRouter, HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer
import jwt
from typing import List
from sqlalchemy.orm import Session
from ..schema.about_yourself import AboutYourself, AboutYourselfORM
from ..api import auth as auth_module

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def get_current_user(token: str = Depends(oauth2_scheme)):
    try:
        payload = jwt.decode(token, auth_module.SECRET_KEY, algorithms=[auth_module.ALGORITHM])
        user_id = payload.get("user_id") or payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")
        return user_id
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid token")

router = APIRouter(tags=["About Yourself"])


@router.get("/about_yourself", response_model=List[AboutYourself])
def get_about_yourself(db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    about_records = db.query(AboutYourselfORM).filter(AboutYourselfORM.user_id == user_id).all()
    return [AboutYourself(
        id=record.id,
        health_description=record.health_description,
        health_goal=record.health_goal,
        user_id=record.user_id
    ) for record in about_records]


@router.get("/about_yourself/{about_id}", response_model=AboutYourself)
def get_about_yourself_item(about_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    record = db.query(AboutYourselfORM).filter(
        AboutYourselfORM.id == about_id,
        AboutYourselfORM.user_id == user_id
    ).first()
    if not record:
        raise HTTPException(status_code=404, detail="About yourself not found")
    return AboutYourself(
        id=record.id,
        health_description=record.health_description,
        health_goal=record.health_goal,
        user_id=record.user_id
    )


@router.post("/about_yourself", response_model=AboutYourself)
def create_about_yourself(about: AboutYourself, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Check if record already exists
    existing = db.query(AboutYourselfORM).filter(AboutYourselfORM.id == about.id).first()
    if existing:
        raise HTTPException(status_code=400, detail="About yourself already exists")
    
    # Create new database record
    db_record = AboutYourselfORM(
        id=about.id,
        health_description=about.health_description,
        health_goal=about.health_goal,
        user_id=user_id
    )
    
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    
    return AboutYourself(
        id=db_record.id,
        health_description=db_record.health_description,
        health_goal=db_record.health_goal,
        user_id=db_record.user_id
    )


@router.put("/about_yourself/{about_id}", response_model=AboutYourself)
def update_about_yourself(about_id: str, about: AboutYourself, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Find existing record
    db_record = db.query(AboutYourselfORM).filter(
        AboutYourselfORM.id == about_id,
        AboutYourselfORM.user_id == user_id
    ).first()
    
    if not db_record:
        raise HTTPException(status_code=404, detail="About yourself not found")
    
    # Update fields
    db_record.health_description = about.health_description
    db_record.health_goal = about.health_goal
    
    db.commit()
    db.refresh(db_record)
    
    return AboutYourself(
        id=db_record.id,
        health_description=db_record.health_description,
        health_goal=db_record.health_goal,
        user_id=db_record.user_id
    )


@router.delete("/about_yourself/{about_id}")
def delete_about_yourself(about_id: str, db: Session = Depends(auth_module.get_db), user_id: str = Depends(get_current_user)):
    # Find existing record
    db_record = db.query(AboutYourselfORM).filter(
        AboutYourselfORM.id == about_id,
        AboutYourselfORM.user_id == user_id
    ).first()
    
    if not db_record:
        raise HTTPException(status_code=404, detail="About yourself not found")
    
    db.delete(db_record)
    db.commit()
    
    return {"detail": "About yourself deleted"}
