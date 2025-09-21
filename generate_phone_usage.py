#!/usr/bin/env python3
"""
generate_phone_usage.py

Generates N days of PhoneUsage documents per student (reads Students collection)
and inserts them into PhoneUsage collection in the specified database.
"""

import argparse
import os
import random
import sys  # <- needed for sys.exit()
from datetime import date, datetime, timedelta
from pymongo import MongoClient, errors

# --- Constants ---
RANDOM_SEED = 42
random.seed(RANDOM_SEED)

ACADEMIC_APPS = ["Google Classroom", "Zoom", "Docs", "Google Meet", "Khan Academy", "Coursera"]
ENTERTAINMENT_APPS = ["YouTube", "Instagram", "WhatsApp", "Snapchat", "Netflix", "Spotify", "Telegram", "Facebook"]

# --- Argument parser ---
def parse_args():
    p = argparse.ArgumentParser(description="Generate phone usage test data for students")
    p.add_argument("--uri", help="MongoDB connection URI (or set MONGODB_URI env var)", default=os.environ.get("MONGODB_URI"))
    p.add_argument("--db", default="wellnessDB", help="Database name (default: wellnessDB)")
    p.add_argument("--students-coll", default="Students", help="Students collection name (default: Students)")
    p.add_argument("--phone-coll", default="PhoneUsage", help="PhoneUsage collection name (default: PhoneUsage)")
    p.add_argument("--days", type=int, default=14, help="Number of days to generate per student (default: 14)")
    p.add_argument("--start-date", type=str, default=None, help="Start date YYYY-MM-DD (default: end_date - days + 1). If omitted, end date is yesterday.")
    p.add_argument("--mode", choices=["skip", "overwrite"], default="skip", help="'skip' existing entries (default) or 'overwrite' them")
    p.add_argument("--dry-run", action="store_true", help="Don't insert into DB; just print summary")
    return p.parse_args()

def get_student_identifier(student_doc):
    for k in ("UserID", "userId", "username", "UserId", "userID"):
        val = student_doc.get(k)
        if val:
            return str(val)
    _id = student_doc.get("_id")
    return str(_id) if _id is not None else None

def generate_daily_usage(curr_date, is_weekday):
    apps = []
    if is_weekday:
        academic_count = random.choice([1, 2])
        ent_count = random.choice([1, 2])
        base_screen = random.randint(180, 360)
    else:
        academic_count = random.choice([0, 1])
        ent_count = random.choice([2, 3])
        base_screen = random.randint(240, 480)

    picked_academic = random.sample(ACADEMIC_APPS, k=min(academic_count, len(ACADEMIC_APPS)))
    picked_ent = random.sample(ENTERTAINMENT_APPS, k=min(ent_count, len(ENTERTAINMENT_APPS)))

    for app in picked_academic:
        dur = random.randint(20, 150)
        apps.append({"appName": app, "durationMinutes": dur})
    for app in picked_ent:
        dur = random.randint(20, 220)
        apps.append({"appName": app, "durationMinutes": dur})

    total_usage = sum(a["durationMinutes"] for a in apps)
    if total_usage < base_screen:
        diff = base_screen - total_usage
        idx = random.randrange(len(apps))
        apps[idx]["durationMinutes"] += diff
        total_usage += diff

    night_usage = random.randint(20, min(120, total_usage)) if is_weekday else random.randint(40, min(180, total_usage))
    night_usage = min(night_usage, total_usage)

    return {
        "date": datetime(curr_date.year, curr_date.month, curr_date.day),
        "screenTime": int(total_usage),
        "nightUsage": int(night_usage),
        "appsUsed": apps,
        "generatedBy": "generate_phone_usage.py",
        "generatedAt": datetime.utcnow()
    }

def main():
    args = parse_args()

    if not args.uri:
        print("ERROR: MongoDB URI not provided. Set MONGODB_URI environment variable or pass --uri.")
        sys.exit(1)

    if args.start_date:
        try:
            start_date = datetime.strptime(args.start_date, "%Y-%m-%d").date()
        except Exception:
            print("Invalid --start-date. Use YYYY-MM-DD.")
            sys.exit(1)
        end_date = start_date + timedelta(days=args.days - 1)
    else:
        end_date = date.today() - timedelta(days=1)
        start_date = end_date - timedelta(days=args.days - 1)

    print(f"Connecting to MongoDB: DB='{args.db}', StudentsColl='{args.students_coll}', PhoneUsageColl='{args.phone_coll}'")
    print(f"Generating data for dates: {start_date} → {end_date} (days={args.days})")
    print(f"Mode: {args.mode}  Dry-run: {args.dry_run}")

    try:
        client = MongoClient(args.uri)
        db = client[args.db]
        students_coll = db[args.students_coll]
        phone_coll = db[args.phone_coll]
    except errors.PyMongoError as e:
        print("MongoDB connection error:", e)
        sys.exit(1)

    students = list(students_coll.find({}))
    print(f"Found {len(students)} students in collection '{args.students_coll}'")

    total_inserted = total_skipped = total_overwritten = 0

    for student in students:
        student_identifier = get_student_identifier(student)
        if not student_identifier:
            print(f"Skipping student with missing identifier: {student.get('_id')}")
            continue

        docs_to_insert = []
        curr = start_date
        while curr <= end_date:
            is_weekday = curr.weekday() < 5
            doc = generate_daily_usage(curr, is_weekday)
            doc["studentId"] = student_identifier
            if student.get("_id") is not None:
                doc["studentObjectId"] = student["_id"]

            exists_filter = {"studentId": student_identifier, "date": doc["date"]}
            exists = phone_coll.count_documents(exists_filter, limit=1) > 0

            if exists:
                if args.mode == "skip":
                    total_skipped += 1
                else:
                    if not args.dry_run:
                        phone_coll.delete_many(exists_filter)
                    docs_to_insert.append(doc)
                    total_overwritten += 1
            else:
                docs_to_insert.append(doc)

            curr += timedelta(days=1)

        if docs_to_insert:
            if args.dry_run:
                print(f"[DRY-RUN] Would insert {len(docs_to_insert)} docs for {student_identifier}")
                total_inserted += len(docs_to_insert)
            else:
                try:
                    res = phone_coll.insert_many(docs_to_insert)
                    total_inserted += len(res.inserted_ids)
                    print(f"Inserted {len(res.inserted_ids)} docs for student '{student_identifier}'")
                except errors.BulkWriteError as bwe:
                    print("Bulk write error:", bwe.details)
                except Exception as e:
                    print("Insertion error for", student_identifier, ":", e)

    print("=== Summary ===")
    print("Total inserted:", total_inserted)
    print("Total skipped (existing, skip mode):", total_skipped)
    print("Total overwritten (when mode=overwrite):", total_overwritten)
    print("Done.")

if __name__ == "__main__":
    main()
