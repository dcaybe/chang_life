import requests
import json
import time
import sys
import io

# Fix unicode error in windows terminal
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

try:
    from deep_translator import GoogleTranslator
except ImportError:
    print("Please install deep-translator: pip install deep-translator")
    sys.exit(1)

# Supabase config
SUPABASE_URL = "https://oywajngcajhacfjfejqp.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95d2FqbmdjYWpoYWNmamZlanFwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk0NzY0NTAsImV4cCI6MjA5NTA1MjQ1MH0.pP2etTSIXXAReF2wlOHPa4Qj9_H7r6mdQ7OSeg85kwY"
HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal"
}

# ExerciseDB API config
API_URL = "https://oss.exercisedb.dev/api/v1/exercises?limit=50"

def translate_text(text):
    if not text: return ""
    try:
        return GoogleTranslator(source='en', target='vi').translate(text)
    except Exception as e:
        print(f"Error: {e}")
        return text

def main():
    print("Loading from ExerciseDB...")
    response = requests.get(API_URL)
    if response.status_code != 200:
        print("Fetch error")
        return
        
    data = response.json()
    if isinstance(data, dict) and "data" in data:
        exercises = data["data"]
    elif isinstance(data, list):
        exercises = data
    else:
        exercises = data.get("exercises", [])
    
    print(f"Loaded {len(exercises)} exercises. Translating and uploading...")
    
    for i, ex in enumerate(exercises):
        time.sleep(0.5) 
        
        ex_id = ex.get('id', str(i))
        name_en = ex.get('name', '')
        name_vi = translate_text(name_en)
        
        instructions_en = ex.get('instructions', [])
        instructions_vi = []
        for step in instructions_en:
            instructions_vi.append(translate_text(step))
            time.sleep(0.1)
            
        payload = {
            "id": ex_id,
            "name_en": name_en,
            "name_vi": name_vi,
            "body_part": ex.get('bodyPart', ''),
            "target": ex.get('target', ''),
            "equipment": ex.get('equipment', ''),
            "gif_url": ex.get('gifUrl', ''),
            "instructions_en": instructions_en,
            "instructions_vi": instructions_vi,
            "secondary_muscles": ex.get('secondaryMuscles', [])
        }
        
        res = requests.post(f"{SUPABASE_URL}/rest/v1/exercises", headers=HEADERS, json=payload)
        if res.status_code in [200, 201]:
            print(f"[{i+1}/{len(exercises)}] Uploaded: {name_vi}")
        else:
            headers_upsert = HEADERS.copy()
            headers_upsert["Prefer"] = "resolution=merge-duplicates"
            res_upsert = requests.post(f"{SUPABASE_URL}/rest/v1/exercises", headers=headers_upsert, json=payload)
            if res_upsert.status_code in [200, 201]:
                print(f"[{i+1}/{len(exercises)}] Updated: {name_vi}")
            else:
                print(f"Upload error {name_en}: {res.status_code} - {res.text}")

if __name__ == "__main__":
    main()
