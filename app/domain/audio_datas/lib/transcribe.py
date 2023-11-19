import whisper
import ffmpeg

model = whisper.load_model("tiny") # "medium"
transcribe_l = 'jp'
options = whisper.DecodingOptions(language = transcribe_l)

# Read the stdin from Ruby
audio_file_path = "/home/tsaiadrian/transound/podcast_mp3_store/【11月9日】OpenAIが最新技術を発表。カスタマイズとストア提供で裾野拡大.mp3"# sys.stdin.read()
result = model.transcribe(audio_file_path)

print(result["text"])