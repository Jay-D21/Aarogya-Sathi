from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE

# --- THEME COLORS ---
BLUE_DARK = RGBColor(15, 23, 42)
BLUE_LIGHT = RGBColor(59, 130, 246)
GREEN_DARK = RGBColor(13, 148, 136)
GRAY_LIGHT = RGBColor(241, 245, 249)
WHITE = RGBColor(255, 255, 255)
TEXT_COLOR = RGBColor(51, 65, 85)

def set_slide_background(slide, color):
    background = slide.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = color

def add_title_slide(prs, title_text, subtitle_text):
    slide_layout = prs.slide_layouts[0]
    slide = prs.slides.add_slide(slide_layout)
    set_slide_background(slide, GRAY_LIGHT)
    
    title = slide.shapes.title
    title.text = title_text
    title.text_frame.paragraphs[0].font.color.rgb = BLUE_DARK
    title.text_frame.paragraphs[0].font.size = Pt(44)
    title.text_frame.paragraphs[0].font.bold = True
    
    subtitle = slide.placeholders[1]
    subtitle.text = subtitle_text
    subtitle.text_frame.paragraphs[0].font.color.rgb = TEXT_COLOR
    subtitle.text_frame.paragraphs[0].font.size = Pt(24)

def add_content_slide(prs, title_text, bullet_points, highlight_color=BLUE_LIGHT):
    slide_layout = prs.slide_layouts[1]
    slide = prs.slides.add_slide(slide_layout)
    
    # Title formatting
    title = slide.shapes.title
    title.text = title_text
    title.text_frame.paragraphs[0].font.color.rgb = BLUE_DARK
    title.text_frame.paragraphs[0].font.size = Pt(32)
    
    # Left Border Accent
    rect = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(0.2), Inches(7.5))
    rect.fill.solid()
    rect.fill.fore_color.rgb = highlight_color
    rect.line.fill.background()
    
    # Content formatting
    body_shape = slide.placeholders[1]
    tf = body_shape.text_frame
    tf.text = "" # Clear default
    
    for point in bullet_points:
        p = tf.add_paragraph()
        p.text = "• " + point
        p.font.size = Pt(18)
        p.font.color.rgb = TEXT_COLOR
        p.space_after = Pt(10)

def add_table_slide(prs, title_text, data):
    slide_layout = prs.slide_layouts[1]
    slide = prs.slides.add_slide(slide_layout)
    title = slide.shapes.title
    title.text = title_text
    
    rows = len(data)
    cols = len(data[0])
    
    # Add table
    left = Inches(0.5)
    top = Inches(1.5)
    width = Inches(9.0)
    height = Inches(5.0)
    
    table = slide.shapes.add_table(rows, cols, left, top, width, height).table
    
    # Set column widths
    for i in range(cols):
        table.columns[i].width = width // cols
        
    for r in range(rows):
        for c in range(cols):
            cell = table.cell(r, c)
            cell.text = data[r][c]
            # Header styling
            if r == 0:
                cell.fill.solid()
                cell.fill.fore_color.rgb = BLUE_DARK
                cell.text_frame.paragraphs[0].font.color.rgb = WHITE
                cell.text_frame.paragraphs[0].font.bold = True
            else:
                cell.fill.solid()
                cell.fill.fore_color.rgb = WHITE
                cell.text_frame.paragraphs[0].font.color.rgb = TEXT_COLOR
            
            cell.text_frame.paragraphs[0].font.size = Pt(12)

def add_code_slide(prs, title_text, code_text):
    slide_layout = prs.slide_layouts[1]
    slide = prs.slides.add_slide(slide_layout)
    title = slide.shapes.title
    title.text = title_text
    
    # Dark background for code
    rect = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.5), Inches(1.3), Inches(9.0), Inches(5.5))
    rect.fill.solid()
    rect.fill.fore_color.rgb = RGBColor(30, 41, 59)
    rect.line.fill.background()
    
    # Code Text
    txBox = slide.shapes.add_textbox(Inches(0.6), Inches(1.4), Inches(8.8), Inches(5.3))
    tf = txBox.text_frame
    tf.word_wrap = True
    p = tf.add_paragraph()
    p.text = code_text
    p.font.name = 'Consolas'
    p.font.size = Pt(11)
    p.font.color.rgb = RGBColor(226, 232, 240)

prs = Presentation()

# 1. Title Slide
add_title_slide(prs, "Aarogya Sathi: ADBMS Core Architecture", 
                "Advanced DBMS Subject Project | 18-Table Schema | PL/pgSQL Implementation")

# 2. Project Vision
add_content_slide(prs, "1. Project Vision & Goals", [
    "Mission: AI-driven companion for medical telemetry and OCR reports.",
    "Goal: High-integrity storage with advanced automated clinical logic.",
    "Scale: Designed for millions of concurrent health-log streams.",
    "Features: Real-time AQI integration, step-tracking, and AI chat."
], GREEN_DARK)

# 3. Database Selection: Why PostgreSQL?
add_content_slide(prs, "2. PostgreSQL 15: Core Engine", [
    "JSONB: Native storage for deeply nested OCR biomarkers extraction.",
    "GIN/GIST Indexes: Fast searching across JSON and geographic data.",
    "PL/pgSQL: Business logic offloading from API to DB layer.",
    "ACID: Guarantees zero data loss for critical health readings.",
    "RLS (Row Level Security): Native user-isolation at the DB level."
])

# 4. Relational Schema - Part 1
schema_data_1 = [
    ["Entity", "Primary Key", "Logical Domain"],
    ["USERS", "UUID", "Core Profile / Auth"],
    ["HEALTH_RECORDS", "UUID", "Telemetry (BP, Sugar, Symptoms)"],
    ["CHAT_HISTORY", "UUID", "AI Interactions & Safety"],
    ["MEDICAL_REPORTS", "UUID", "OCR Data & Lab Biomarkers"],
    ["ENV_ALERTS", "UUID", "Location-based AQI / Thresholds"],
    ["HEALTH_CONDITIONS", "UUID", "Chronic Condition Management"]
]
add_table_slide(prs, "3. Relational Schema: Core Entities (1/3)", schema_data_1)

# 5. Relational Schema - Part 2
schema_data_2 = [
    ["Entity", "Primary Key", "Logical Domain"],
    ["USER_PREFERENCES", "UUID", "App & Alert Configurations"],
    ["AUTH_SESSIONS", "UUID", "JWT Security & Devices"],
    ["ABDM_INTEGRATIONS", "UUID", "ABHA ID / Digital Health Mission"],
    ["SUBSCRIPTIONS", "UUID", "Billing & Plan Management"],
    ["USER_ANALYTICS", "UUID", "Engagement Metrics & Active Days"],
    ["API_USAGE", "UUID", "LLM Token & Cost Tracking"]
]
add_table_slide(prs, "4. Relational Schema: Systems (2/3)", schema_data_2)

# 6. Relational Schema - Part 3
schema_data_3 = [
    ["Entity", "Primary Key", "Logical Domain"],
    ["USER_FEEDBACK", "UUID", "Quality Assurance"],
    ["CORP_ACCOUNTS", "UUID", "Wellness Programs / B2B"],
    ["DAILY_STEPS", "UUID", "Activity Tracking (Virtual Nurse)"],
    ["WORKOUTS", "UUID", "Fitness Logs"],
    ["REMINDERS", "UUID", "Medication/Water Scheduling"],
    ["HEALTH_AUDIT", "UUID", "CDC / Safety Audit Logs"]
]
add_table_slide(prs, "5. Relational Schema: Virtual Nurse (3/3)", schema_data_3)

# 7. EER & Normalization
add_content_slide(prs, "6. EER & BCNF Normalization", [
    "BCNF: All determinants are candidate keys; zero transitive dependencies.",
    "Total Disjoint Specialization: HEALTH_RECORDS → (Vitals, Symptoms, Medication).",
    "Mapping: Single-Table Inheritance (STI) with Discriminator Enums.",
    "Domains: Custom types (email_domain, bp_reading) ensure strict typing.",
    "Multi-valued attributes: Handled via JSONB arrays for allergens/symptoms."
])

# 8. Data Flow: App to AI
add_content_slide(prs, "7. Data Flow & Architecture", [
    "App Layer: User logs vital via Flutter UI.",
    "API Layer: FastAPI receives JSON, calls sp_log_health_record().",
    "DBMS Layer: Trigger scans for critical thresholds (BP > 140).",
    "Alert Layer: Procedure auto-inserts into ENV_ALERTS if abnormal.",
    "AI Layer: Retrieval-Augmented Generation (RAG) fetches DB logs for Chat context."
], GREEN_DARK)

# 9. PL/SQL: Procedure Example
code_proc = """CREATE OR REPLACE PROCEDURE sp_log_health_record(
    p_user_id UUID, p_type VARCHAR, p_systolic INT, p_diastolic INT
) LANGUAGE plpgsql AS $$
BEGIN
    -- Atomic Insert
    INSERT INTO health_records (user_id, record_type, bp_systolic, bp_diastolic)
    VALUES (p_user_id, p_type, p_systolic, p_diastolic);
    
    -- Emergency Safety Logic in DB
    IF p_systolic > 180 THEN
        INSERT INTO environmental_alerts (user_id, alert_type, alert_severity)
        VALUES (p_user_id, 'health_threshold', 'critical');
    END IF;
    
    COMMIT;
END; $$;"""
add_code_slide(prs, "8. Automation: Stored Procedures", code_proc)

# 10. PL/SQL: Trigger Example
code_trig = """CREATE OR REPLACE FUNCTION trg_fn_emergency_alert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contained_emergency_keywords = true THEN
        INSERT INTO environmental_alerts (user_id, alert_type, alert_title)
        VALUES (NEW.user_id, 'emergency', '🚨 Emergency Detected');
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_emergency_alert
    AFTER INSERT ON chat_history
    FOR EACH ROW WHEN (NEW.contained_emergency_keywords = true)
    EXECUTE FUNCTION trg_fn_emergency_alert();"""
add_code_slide(prs, "9. Event-Driven: Triggers", code_trig)

# 11. PL/SQL: Advanced Functions
code_fn = """CREATE OR REPLACE FUNCTION fn_calculate_risk_score(p_user_id UUID)
RETURNS INT AS $$
DECLARE v_score INT := 0;
BEGIN
    -- Weighted logic based on recent readings
    SELECT (AVG(bp_systolic) - 120) * 2 INTO v_score 
    FROM health_records WHERE user_id = p_user_id AND bp_systolic > 120;
    
    -- Add condition weight
    v_score := v_score + (SELECT COUNT(*) * 10 FROM health_conditions 
                          WHERE user_id = p_user_id);
    RETURN LEAST(v_score, 100);
END; $$ LANGUAGE plpgsql;"""
add_code_slide(prs, "10. Analytics: Custom Functions", code_fn)

# 12. Optimization: Indexing & Partitioning
add_content_slide(prs, "11. Optimization Strategy", [
    "Partitioning: Range-partitioning for CHAT_HISTORY by Month/Year.",
    "GIN Index: Fast retrieval of nested JSONB biomarkers in reports.",
    "B-Tree Composite: (user_id, recorded_at) for efficient history scans.",
    "Materialized Views: Cached daily platform-wide analytics summary.",
    "Partial Indexes: Target active sessions only, reducing index size."
], BLUE_DARK)

# 13. Security & Compliance
add_content_slide(prs, "12. Security & Compliance", [
    "RLS Policies: Native SQL level 'WHERE user_id = current_user'.",
    "Encryption: AES-256 at rest; password_hash via bcrypt.",
    "Soft Deletion: DPDP compliance via 'deleted_at' flag and redacted strings.",
    "Audit Logs: Separate table tracking every health_record modification."
])

# 14. Conclusion
add_title_slide(prs, "Thank You!", "Questions on BCNF, PL/pgSQL, or AI-DB Integration?")

prs.save('Aarogya_Sathi_ADBMS_Visual_Presentation.pptx')
print("Visual Presentation generated successfully.")
