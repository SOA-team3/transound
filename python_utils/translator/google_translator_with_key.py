from google.cloud import translate_v2 as translate
import sys

# # Split the stdin parameter
# para = sys.stdin.read()
# TEXT = para.split('\n')[0]
# translate_language = para.split('\n')[1]

# Translate the text by googletrans
def translate_text(api_key: str, target: str, text: str) -> dict:
    """Translates text into the target language.

    Target must be an ISO 639-1 language code.
    See https://g.co/cloud/translate/v2/translate-reference#supported_languages
    """
    from google.cloud import translate_v2 as translate

    # 使用提供的 API 金鑰建立 translate 客戶端
    translate_client = translate.Client(api_key=api_key)

    if isinstance(text, bytes):
        text = text.decode("utf-8")

    # Text 可以是一個字符串，也可以是一個字符串序列
    result = translate_client.translate(text, target_language=target)

    print("Text: {}".format(result["input"]))
    print("Translation: {}".format(result["translatedText"]))
    print("Detected source language: {}".format(result["detectedSourceLanguage"]))

    return result

TEXT = "These Tiny Pollinators Can Travel Surprisingly Huge Distances."
translate_language = "zh-tw"
api_key = "AIzaSyB7-AoI-My5fcPWI74voWYCA6qwvTEQsC4"
output = translate_text(api_key, translate_language, TEXT)
print(output)

