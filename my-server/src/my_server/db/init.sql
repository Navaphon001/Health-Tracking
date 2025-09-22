-- Enums
CREATE TYPE "gender" AS ENUM ('male', 'female', 'other');
CREATE TYPE "meal_type" AS ENUM ('breakfast', 'lunch', 'dinner', 'snack');
CREATE TYPE "theme" AS ENUM ('light', 'dark', 'system');
CREATE TYPE "weight_unit" AS ENUM ('kg', 'lbs');
CREATE TYPE "height_unit" AS ENUM ('cm', 'ft_in');
CREATE TYPE "temperature_unit" AS ENUM ('celsius', 'fahrenheit');
CREATE TYPE "activity_type" AS ENUM ('walking', 'running', 'cycling', 'swimming', 'yoga', 'other');
CREATE TYPE "sleep_quality" AS ENUM ('very_poor', 'poor', 'average', 'good', 'excellent');

-- Tables
CREATE TABLE "users" (
  "id" varchar PRIMARY KEY,
  "username" varchar,
  "email" varchar,
  "password" varchar,
  "createdAt" timestamp
);

CREATE TABLE "basic_profile" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "full_name" varchar,
  "date_of_birth" date,
  "gender" gender,
  "profile_image_url" varchar,
  "phone_number" varchar,
  "address" text,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "user_goals" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "goal_type" varchar,
  "goal_value" double precision,
  "goal_current" double precision,
  "start_date" date,
  "end_date" date,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "food_logs" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "date" date NOT NULL,
  "last_modified" timestamp DEFAULT (now()),
  "meal_count" integer DEFAULT 0
);

CREATE TABLE "meals" (
  "id" varchar PRIMARY KEY,
  "food_log_id" varchar NOT NULL,
  "user_id" varchar NOT NULL,
  "food_name" varchar,
  "meal_type" meal_type,
  "image_url" varchar,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "achievements" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "type" varchar,
  "name" varchar,
  "description" text,
  "target" integer,
  "current" integer,
  "achieved" boolean DEFAULT false,
  "achieved_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "nutrition_database" (
  "id" varchar PRIMARY KEY,
  "food_name" varchar NOT NULL,
  "calories" double precision,
  "protein" double precision,
  "carbs" double precision,
  "fat" double precision,
  "fiber" double precision,
  "sugar" double precision,
  "last_updated" timestamp DEFAULT (now())
);

CREATE TABLE "exercise_logs" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "date" date NOT NULL,
  "activity_type" activity_type,
  "duration" integer,
  "calories_burned" double precision,
  "notes" text,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "sleep_logs" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "date" date NOT NULL,
  "bed_time" time,
  "wake_time" time,
  "sleep_quality" sleep_quality,
  "notes" text,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "water_intake_logs" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "date" date NOT NULL,
  "count" integer,
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "notification_settings" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "water_reminder_enabled" boolean DEFAULT true,
  "exercise_reminder_enabled" boolean DEFAULT true,
  "meal_logging_enabled" boolean DEFAULT true,
  "sleep_reminder_enabled" boolean DEFAULT true,
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "physical_info" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "weight" double precision,
  "height" double precision,
  "activity_level" varchar,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "about_yourself" (
  "id" varchar PRIMARY KEY,
  "user_id" varchar NOT NULL,
  "health_description" text,
  "health_goal" text,
  "updated_at" timestamp DEFAULT (now())
);

-- Indexes
CREATE UNIQUE INDEX ON "users" ("email");
CREATE UNIQUE INDEX ON "users" ("id");
CREATE INDEX ON "basic_profile" ("user_id");
CREATE INDEX ON "user_goals" ("user_id");
CREATE INDEX ON "user_goals" ("user_id", "is_active");
CREATE INDEX ON "user_goals" ("user_id", "start_date");
CREATE UNIQUE INDEX ON "food_logs" ("user_id", "date");
CREATE INDEX ON "food_logs" ("date");
CREATE INDEX ON "meals" ("food_log_id");
CREATE INDEX ON "meals" ("user_id");
CREATE INDEX ON "meals" ("meal_type");
CREATE INDEX ON "meals" ("created_at");
CREATE INDEX ON "achievements" ("user_id");
CREATE INDEX ON "achievements" ("type");
CREATE INDEX ON "achievements" ("achieved");
CREATE UNIQUE INDEX ON "nutrition_database" ("food_name");
CREATE INDEX ON "exercise_logs" ("user_id");
CREATE INDEX ON "exercise_logs" ("date");
CREATE INDEX ON "exercise_logs" ("activity_type");
CREATE INDEX ON "sleep_logs" ("user_id");
CREATE INDEX ON "sleep_logs" ("date");
CREATE INDEX ON "water_intake_logs" ("user_id");
CREATE INDEX ON "water_intake_logs" ("date");
CREATE INDEX ON "notification_settings" ("user_id");
CREATE INDEX ON "physical_info" ("user_id");
CREATE INDEX ON "about_yourself" ("user_id");

-- Foreign Keys
ALTER TABLE "basic_profile" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "user_goals" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "food_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "meals" ADD FOREIGN KEY ("food_log_id") REFERENCES "food_logs" ("id");
ALTER TABLE "meals" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "achievements" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "exercise_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "sleep_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "water_intake_logs" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "notification_settings" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "physical_info" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
ALTER TABLE "about_yourself" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");
