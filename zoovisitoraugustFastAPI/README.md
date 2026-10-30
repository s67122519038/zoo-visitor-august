# CPE5013 — Zoo Visitors FY2569 (FastAPI)

โปรเจกต์ RESTful API รายงานสถิติผู้เข้าชมสวนสัตว์ ปีงบประมาณ **พ.ศ. 2569** โดยอ้างอิงจากหน่วยงาน **องค์การสวนสัตว์แห่งประเทศไทย ในพระบรมราชูปถัมภ์** และ **Data.go.th**

- ชุดข้อมูล: <https://data.go.th/dataset/zoo-visitors2569>
- Resource ID ตามโจทย์: `0ecc96cf-d914-42a1-b184-dbbd013c3c9c` (ยังไม่สามารถตรวจยืนยันผ่าน Data API)
- Resource ID เดือนสิงหาคม 2569 ที่หน้าชุดข้อมูลระบุ: `57a5cad9-d533-4bd1-b3a5-e310bc13eeaa`
- ประเภทต้นทาง: Data.go.th CKAN API หรือไฟล์ CSV/XLSX ที่ดาวน์โหลดจริง

## 1. ติดตั้งและเปิดบน Windows 11

เปิด **CMD** ภายในโฟลเดอร์ที่แตก ZIP:

```bat
py -m venv .venv
.venv\Scripts\activate
python -m pip install -r requirements.txt
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

ถ้าติดตั้งครบแล้ว ครั้งต่อไปใช้แค่:

```bat
cd path\to\Zoo_Visitors_2569_FastAPI
.venv\Scripts\activate
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

ทดสอบใน Browser:
- Swagger UI: <http://127.0.0.1:8000/docs>
- GET API: <http://127.0.0.1:8000/api/zoo-visitors?limit=5>
- Health check: <http://127.0.0.1:8000/health>

FastAPI จะสร้าง `/docs` และ `/openapi.json` ให้อัตโนมัติ

## 2. สำคัญมาก — ต้องแยก "ไฟล์ต้นฉบับ" กับ "ข้อมูลตัวอย่างที่ตรวจสอบได้"

API รองรับ `source` 4 แบบ:

| source | พฤติกรรม | เหมาะส่งงาน? |
|---|---|---|
| `live` | เรียก Data.go.th CKAN Data API โดยตรง และระบุ Resource ID ใน JSON | **ใช่** เมื่อ API ให้ผลจริง |
| `file` | อ่านไฟล์ CSV/XLSX ของทางการที่คุณดาวน์โหลดเอง | **ใช่** และเชื่อถือได้สูง |
| `excerpt` | อ่าน 12 แถวจริงที่ตรวจจากตาราง Data.go.th เดือนสิงหาคม 2569 และบอกชัดว่าไม่ใช่ทั้งไฟล์ | สำหรับตรวจโค้ดเบื้องต้น **ไม่ใช่ไฟล์ต้นฉบับเต็ม** |
| `auto` | ใช้ไฟล์ของทางการก่อน (ถ้ามี), ไม่เช่นนั้นเรียก API, ถ้าใช้ไม่ได้จึงใช้ excerpt พร้อมป้ายบอก | ดู `source.type` ก่อนนำไปอ้างเป็นหลักฐาน |

### วิธีที่แนะนำที่สุดสำหรับการส่งอาจารย์

1. เปิด <https://data.go.th/dataset/zoo-visitors2569>
2. คลิกทรัพยากรรายเดือนที่ต้องการ เลือกไฟล์ **CSV หรือ XLSX** จาก Data.go.th และดาวน์โหลดไฟล์จริง
3. เปลี่ยนชื่อไฟล์เป็น `zoo_visitors_2569.csv` หรือ `zoo_visitors_2569.xlsx`
4. วางไฟล์ในโฟลเดอร์ `data/` ข้าง `verified_portal_excerpt_2569.csv`
5. เปิด <http://127.0.0.1:8000/api/zoo-visitors?source=file&limit=5> แล้วตรวจให้ `source.type` เป็น `official_downloaded_file`
6. แนบภาพหน้าชุดข้อมูล Data.go.th ที่แสดง Resource ID / วันปรับปรุง พร้อมภาพ Postman JSON รายการตัวเลขจากไฟล์นั้น

โค้ด **ไม่กำหนดชื่อคอลัมน์ข้อมูลตายตัว** โดยดึงหัวตารางจริงของ CSV/XLSX เป็น key ของ JSON ถ้าต้นทางมีคอลัมน์ไม่เหมือนตัวอย่างก็ยังส่งคืนรายการตามต้นฉบับ

หมายเหตุ: Excel ที่มีหลายแถวหัวเรื่องก่อนหัวตาราง อาจต้องเลือก/จัดแถวหัวตารางก่อนนำเข้า โปรแกรมอ่านแถวแรกที่มีข้อมูล 2 ช่องขึ้นไปเป็นชื่อคอลัมน์ หากไฟล์จริงใช้รูปแบบพิเศษ ให้ปรับตามทรัพยากรที่ดาวน์โหลด

## 3. API ของ Data.go.th (Live)

Endpoint อ้างอิงจากคู่มือ CKAN Data API ของ Data.go.th:

```text
https://opend.data.go.th/get-ckan/datastore_search?resource_id=0ecc96cf-d914-42a1-b184-dbbd013c3c9c&limit=5
```

การทดสอบ API ผ่านระบบสร้างโปรเจกต์นี้ยังเข้าไม่ถึง จึง **ไม่ได้อ้างว่า Resource ID นี้ดึงข้อมูลสำเร็จแล้ว**; โปรแกรมลองรหัสเดือนสิงหาคมที่หน้าชุดข้อมูลแสดงให้โดยอัตโนมัติถ้ารหัสโจทย์ใช้ไม่ได้

หาก Data.go.th ต้องใช้ API Key ให้ตั้งค่าที่ environment (อย่าเขียนรหัสลงใน Source Code):

```bat
set DATA_GO_TH_API_KEY=YOUR_KEY_FROM_DATA_GO_TH
```

แล้วเปิดเซิร์ฟเวอร์ใน CMD หน้าต่างเดียวกัน การเรียก API ที่ `?source=live` จะคืน **503** หาก Data.go.th ไม่ตอบหรือข้อมูลไม่ตรงกับปี 2569 แทนการสร้างข้อมูลปลอม

## 4. ตัวอย่าง JSON จริงจาก excerpt ที่ตรวจบนเว็บภาครัฐ

ทดสอบ: `GET /api/zoo-visitors?source=excerpt&limit=1`

```json
{
  "success": true,
  "fiscal_year": 2569,
  "source": {
    "dataset": "zoo-visitors2569",
    "dataset_url": "https://data.go.th/dataset/zoo-visitors2569",
    "type": "verified_portal_table_excerpt",
    "is_complete_resource": false
  },
  "total": 12,
  "count": 1,
  "data": [
    {
      "_id": 1,
      "รายการ": "ผู้ใหญ่",
      "สวนสัตว์": "สวนสัตว์เปิดเขาเขียว",
      "ปีงบประมาณ": 2569,
      "ต.ค. 68": 59893,
      "พ.ย. 68": 31752
    }
  ]
}
```

ตัวอย่างย่อ: Response จริงมี `limit`, `offset`, `columns` และคอลัมน์เดือนอื่นเพิ่มเติม ชื่อ Source บอกว่าเป็น **ตัวอย่าง 12 แถว ไม่ใช่ไฟล์ต้นฉบับทั้งชุด** ตัวเลข 59,893 มาจากตารางผู้ใหญ่สวนสัตว์เปิดเขาเขียว บน Data.go.th เดือนสิงหาคม 2569

## 5. Postman

Import `Zoo_Visitors_2569_Postman.json` แล้วกด Send ทีละรายการ:

- `GET /health` → 200
- `GET /docs` → 200 (HTML ของ Swagger UI)
- `GET /api/zoo-visitors?source=excerpt&limit=5` → 200 พร้อม JSON ข้อมูลจริงจากหน้า Data.go.th
- `GET /api/zoo-visitors?source=file&limit=5` → 200 หลังวางไฟล์ทางการ; หากยังไม่มีไฟล์จะได้ **503** ซึ่งเป็นการแจ้งข้อเท็จจริง
- `GET /api/zoo-visitors?source=live&limit=5` → 200 เมื่อ Data.go.th API ติดต่อได้; มิฉะนั้น **503**

ให้ถ่ายภาพ Postman ที่เห็น **Method, URL, Status 200, JSON Response** โดยเฉพาะ `source=file` หรือ `source=live`

## 6. ให้ผู้สอนเข้าผ่าน Public HTTPS (ต้องเป็น URL/Port ที่ได้รับอนุญาต)

โปรเจกต์ของคุณมี LINE Chatbot ใช้ Cloudflare Tunnel พอร์ต 3000 อยู่แล้ว **อย่าเปลี่ยน Tunnel / Webhook ของ LINE**

บน Windows เปิด CMD แยกอีก 2 หน้าต่าง:

**หน้าต่าง A**
```bat
cd path\to\Zoo_Visitors_2569_FastAPI
.venv\Scripts\activate
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

**หน้าต่าง B**
```bat
cloudflared tunnel --url http://127.0.0.1:8000
```

Cloudflare จะแสดง URL ใหม่ `https://<new-name>.trycloudflare.com`; ลิงก์สำหรับส่งอาจารย์:

- `https://<new-name>.trycloudflare.com/api/zoo-visitors?source=file&limit=5`
- `https://<new-name>.trycloudflare.com/docs`

**สำคัญ:** URL ตัวอย่างนี้ไม่ใช่ลิงก์จริงจนกว่าจะรัน Tunnel สำเร็จ และ Quick Tunnel ไม่เสถียรถ้าปิด CMD/ปิดเครื่อง ควรใช้ช่องทางที่สถาบันอนุญาต หรือ Named Tunnel/VPS สำหรับ URL คงที่

## 7. ตรวจโค้ดด้วย pytest

```bat
python -m pytest -q
```

Unit tests ใช้ CSV excerpt ที่มีตัวเลขจริง และ mock ข้อมูลเมื่อทดสอบตัวสลับ Live Mode โดย **ไม่อ้างว่าเชื่อม CKAN จริงสำเร็จ**

## 8. สิ่งที่ต้องส่ง

1. URL API สาธารณะ (ยืนยัน URL จริงหลัง Deploy แล้ว)
2. URL `/docs` สาธารณะ
3. ภาพ Postman แสดง Method `GET`, Status `200`, JSON ที่มี FY2569, source และรายการจริง
4. Source Code `main.py`, `requirements.txt`, `data/zoo_visitors_2569.csv` ที่ดาวน์โหลดจาก Data.go.th จริง หรือหลักฐาน `source=live`
5. ภาพหน้า Data.go.th ที่แสดงชื่อทรัพยากรและ Resource ID / เดือนที่ใช้
6. จัด deploy บน URL/Port ที่ได้รับอนุญาตจากผู้สอน

## ความถูกต้องและข้อจำกัด

- ข้อมูลใน `verified_portal_excerpt_2569.csv` มี **12 รายการที่ปรากฏบนตารางเว็บภาครัฐ** ไม่ใช่ไฟล์ CSV ของทางการทั้ง 63 แถว
- ห้ามนำ `source=excerpt` ไปอ้างว่าดาวน์โหลดไฟล์ทรัพยากรต้นฉบับสำเร็จ
- ไม่สร้างตัวเลขที่ไม่มีอยู่ในเอกสาร และไม่ส่ง JSON จำลองเป็นผล Data.go.th จริง
- ปีงบประมาณ 2569 ครอบคลุม ตุลาคม 2568 ถึง กันยายน 2569
