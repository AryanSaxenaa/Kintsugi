# Kintsugi - Washing Machine Diagnostic App

<div align="center">
  <img src="assets/app-images/washing-machine.png" alt="Kintsugi Logo" width="200"/>
  
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://android.com/)
</div>

Kintsugi is a Samsung-themed mobile assistant that helps users troubleshoot washing-machine issues through chat, audio/image analysis, and quick escalations.
Beyond the Flutter app, Kintsugi integrates multiple AI services you built:

RAG Samsung Manual Chatbot (LangChain + Chroma + Gradio)

Multi-Modal AI Chatbot Orchestrator (text/image/audio + Groq summaries)

Image Color Classifier (Rust/Zinc/Normal via OpenCV heuristics)

Hierarchical Audio Classifier (Mel-spectrogram CNNs for sound anomalies)

The mobile app can work standalone as a frontend today, and you can wire it to these services when ready.

🌟 Key Features (Mobile)

🤖 AI-Powered Chat Interface (diagnostic conversation)

🎙️ Audio Recording (WAV, 16 kHz, mono, PCM16)

📷 Image Attachments (auto-compression, PNG/JPG)

🚨 Escalation System (static ticket generation)

🎨 Samsung Theme (primary #1428A0)

📱 Android-first (responsive UI)

Core Screens

splash_screen.dart — branding

onboarding_screen.dart

login_screen.dart — demo credentials

chat_screen.dart — main diagnostic chat

escalation_screen.dart — submit service request

Services

kintsugi_api_service.dart — (future) API comms

escalation_service.dart — static tickets

audio_recorder_service.dart — recording

Android Permissions

INTERNET, RECORD_AUDIO, CAMERA, READ/WRITE_EXTERNAL_STORAGE

🏗️ End-to-End Architecture (At a Glance)

Kintsugi App (Flutter)
→ sends requests / uploads → API Gateway (planned)
→ routes to one of the AI services:

Manual QA → RAG Samsung Manual Chatbot (LangChain + Chroma + FLAN-T5)

Image Diagnostics → Image Color Classifier (OpenCV, Lab-space heuristics)

Audio Diagnostics → Hierarchical Audio Classifier (Mel-spec CNN, 2-stage)

General Chat / Mixed Inputs → Multi-Modal Chatbot Orchestrator (Gradio clients + Groq summarization)

Responses (and any summaries) are rendered back in the Chat UI with persistent conversation history.

📱 Mobile App (Flutter/Dart)
Setup
git clone https://github.com/AryanSaxenaa/KintsugiNew.git
cd Kintsugi
flutter pub get
flutter doctor
flutter run


Demo credentials:
Email: user@demo.com
Password: demo123

Build
# Debug
flutter run --debug

# Release APK
flutter build apk --release

# Release App Bundle
flutter build appbundle --release

Typical Use

Launch app → onboarding → login

Chat your issue (attach photos/audio if needed)

Submit escalation with details → get ticket ID

🧩 Integrated AI Services (Backends)

Below are the unified READMEs + methodologies for each service, adapted to slot under Kintsugi.

1) RAG Samsung Manual Chatbot

A LangChain + Gradio chatbot that answers from a Samsung manual using embeddings + ChromaDB and conversational memory.

Project Structure
LLM_chatbot2/
├── chroma_db/           # Persistent Chroma vector DB
├── temp_docs/           # Place samsung_manual.txt here
├── app.py               # Gradio app
├── requirements.txt
└── README.md

Methodology

Document Ingestion

Load temp_docs/samsung_manual.txt as UTF-8.

If missing, fail fast with a clear error.

Preprocessing & Chunking

RecursiveCharacterTextSplitter with chunk_size=1000, chunk_overlap=200.

Embedding

sentence-transformers/all-MiniLM-L6-v2 via HuggingFaceEmbeddings

good latency/quality trade-off.

Vector Store (Persistence)

ChromaDB at chroma_db/.

First run builds + persists; later runs load (fast startup).

Retriever

k=2 top chunks per query.

LLM Generation

google/flan-t5-base via pipeline("text2text-generation")
max_length=512, temperature=0.1, top_p=0.95, repetition_penalty=1.2.

Conversational Orchestration

ConversationalRetrievalChain with ConversationBufferMemory(return_messages=True).

UI (Gradio)

Status banner (built vs loaded DB), gr.Chatbot, input box, submit wrapper.

Operational Notes

Reindex: delete chroma_db/.

Swap documents: replace temp_docs/samsung_manual.txt (prefer plain text).

Change models: edit MODEL_NAME_EMBEDDINGS / MODEL_ID_LLM.

Quality & Evaluation (Lightweight)

Grounding checks, follow-up coherence, first-run vs warm-start latency.

Limitations

Works best with clean text; convert PDFs first.

flan-t5-base is compact; upgrade if you need higher fidelity.

Tune k if you miss context.

Install & Run
git clone https://github.com/Anvit25/LLM_chatbot2.git
cd LLM_chatbot2
pip install -r requirements.txt
python app.py
# open http://127.0.0.1:7860

2) Multi-Modal AI Chatbot Orchestrator

A unified Gradio UI that routes between text chat, local semantic image search, image analysis, and audio analysis, with Groq summarization for complex outputs.

Methodology

Input Handling

Multimodal textbox (text/image/audio).

Intent Classification

Rule-based (intents.json):

"chat" → hosted chatbot LLM

"search_local_image" → local semantic search

"request_image_analysis" → ask user to upload image

"request_audio_analysis" → ask user to upload audio

Local Semantic Search

image.json provides descriptions for images under /images/.

Encode with all-MiniLM-L6-v2, cosine similarity; if sim > 0.4, return best image.

Image Analysis Workflow

Send to a vision Gradio client → get raw JSON → summarize via Groq (Llama-3.3-70B) for clear, concise user text.

Audio Analysis Workflow

Send audio to audio Gradio client → return human-readable result.

Groq Summarization

Converts technical JSON to friendly prose.

Conversation Management

History preserved for context; multimodal outputs rendered inline.

Architecture Flow

User (Text/Image/Audio)
    ↓
Intent Classifier (intents.json rules)
    ├─ Chat → Chatbot Client (LLM)
    ├─ Search Local Image → Embedding Match
    ├─ Image Analysis → Vision Client + Groq Summary
    └─ Audio Analysis → Audio Client
    ↓
Response Generator (Groq + History)
    ↓
Gradio Chat UI


Setup

.env with GROQ_API_KEY=...

Dependencies: gradio, gradio_client, sentence-transformers, numpy, requests, python-dotenv

3) Image Color Classifier (Rust / Zinc / Normal)

Goal: Fast, explainable detection of rustish/zincish tendencies using CIELab channel heuristics, plus dominant color palette via K-Means.

Pipeline

Input & Preprocess

Read image, optional resize (speed).

Color Spaces

Convert BGR→RGB/HSV/Lab; compute per-space stats.

Dominant Colors

cv.kmeans (k=3 by default), palette image + shares.

Lab Heuristics

Medians a_med, b_med; thresholds with Δ = lab_delta = 6.0.

rustish_ratio = mean(a* > a_med + Δ)

zincish_ratio = mean(b* > b_med + Δ)

Rule Decision

if zincish_ratio > zinc_thr → zinc

elif rustish_ratio > rust_thr → rust

else → normal

Defaults & Tuning

k=3, lab_delta=6.0, rust_thr=0.01, zinc_thr=0.02

Increase lab_delta to be stricter; decrease thresholds to increase sensitivity.

Components

FastAPI (/classify/): JSON with label, ratios, palette.

Gradio UI: sliders for k, thresholds, lab_delta.

CLI: generate reports + palette images to color_out/.

Quickstart

requirements.txt (fixed)

fastapi[all]
uvicorn
opencv-python-headless
numpy
gradio


Run API

uvicorn api:app --host 127.0.0.1 --port 8000
# docs: http://127.0.0.1:8000/docs


Run Gradio

python gradio_app.py


cURL Example

curl -X POST "http://127.0.0.1:8000/classify/?k=3&rust_thr=0.01&zinc_thr=0.02&lab_delta=6.0" -F "file=@/path/to/img.jpg"


Notes & Limits

Lighting and background affect Lab ratios; encourage consistent, diffuse light.

Heuristic screening, not material certification.

4) Hierarchical Audio Classifier (Washing-Machine Sounds)

Two-stage CNN pipeline on Mel-spectrograms:

Stage-1: Normal vs Abnormal

Stage-2: If Abnormal → (e.g., Dehydration noise); If Normal → (e.g., Wash/Spin)

Methodology

Data

.wav mono clips; group-aware split to avoid leakage.

Preprocessing

sr=22050, n_fft=2048, hop_length=512, n_mels=128

Log-Mel dB, render 224×224 PNG, normalize to [0,1].

Models (per head)

Simple CNN:

Conv2D(32) → MP → Conv2D(64) → MP → Conv2D(128) → MP → Flatten → Dense(128) → Dropout(0.3) → Dense(softmax)

Loss: Sparse CCE, Optimizer: Adam, Metric: Accuracy

Batch 32, ~10 epochs (baseline), tf.data cache/prefetch

Inference Flow

Stage-1 predicts Normal/Abnormal

Route to corresponding Stage-2 head

Return final label + both confidences

Evaluation

Per-stage accuracy/F1 + confusion matrices

End-to-end “hierarchical accuracy”; calibration (ECE) optional

Deployment

Artifacts:

saved_models/{stage1,abnormal,normal}.h5

saved_models/label_meta.json (class index ↔ name)

Repo Layout (example)
├── app.py                 # Gradio prediction UI
├── dl.py                  # Training (builds spectrograms + trains)
├── extractaudio.py        # Quick single-file test
├── data_pipeline.py
├── requirements.txt
├── MelSpectrograms/
└── saved_models/

🧠 Unified Methodology (System Level)

Problem Framing

Users describe issues via chat, images, and audio.

Kintsugi orchestrates the correct backend: manual QA, visual color screening, audio anomaly detection, or general chat.

Routing / Intent

Rule-based intents (intents.json) in the orchestrator decide where to send the request. The Flutter app can mirror this or defer entirely to the gateway.

Retrieval & Generation

For manual questions, RAG retrieves top-k chunks (k=2) from Chroma and FLAN-T5 generates grounded answers with chat memory.

Image Diagnosis

Color-space heuristics identify rustish/zincish tendencies; palette + JSON provides explainability for technicians.

Audio Diagnosis

Two-stage CNN classifies sounds from spectrograms; useful confidence readouts.

Summarization & UX

Complex outputs (e.g., raw JSON) are summarized by Groq (Llama-3.3-70B) for user-friendly chat responses.

🔌 Wiring Kintsugi to the Services (Roadmap)

Add a Gateway (FastAPI or Node) with routes like:

POST /diagnose/image → Image Color Classifier

POST /diagnose/audio → Audio Classifier

POST /qa/manual → RAG Chatbot

POST /chat/multimodal → Orchestrator

Update kintsugi_api_service.dart to call these endpoints:

Multipart for images/audio

JSON for text prompts

Map responses to chat message types in chat_screen.dart.

🧪 Testing (Mobile)
flutter test
flutter test --coverage


Manual checklist: app launches, chat flows, attachments compress, audio records, escalation form validates, navigation smooth, permissions requested.

🔮 Future Work

Hybrid intent detection (rules + semantic)

Vector DB for scalable image/doc retrieval

MobileNet/EfficientNet for audio classifier

Dockerize/CI for services

iOS support, push notifications, multilingual UI

🤝 Contributing

Fork

Create feature branch

Commit + push

PR with tests + docs updates

📄 License

MIT (recommended). Include a LICENSE file.

🔗 Repositories

Kintsugi (Flutter): https://github.com/AryanSaxenaa/KintsugiNew

RAG Chatbot: https://github.com/Anvit25/LLM_chatbot2

(Add orchestrator / classifier repos when you publish them)

🆘 Support

Email: support@kintsugi.app

GitHub Issues (Kintsugi): https://github.com/AryanSaxenaa/KintsugiNew/issues
