import pathlib
import textwrap

import google.generativeai as genai

from IPython.display import display
from IPython.display import Markdown

def to_markdown(text):
  text = text.replace('•', '  *')
  return Markdown(textwrap.indent(text, '> ', predicate=lambda _: True))

# Used to securely store your API key
from google.colab import userdata

GOOGLE_API_KEY=userdata.get('AIzaSyAc7J9U_ozdloNr3cjlT4z2OVV6MfUA3lE')

genai.configure(api_key=GOOGLE_API_KEY)

for m in genai.list_models():
  if 'generateContent' in m.supported_generation_methods:
    print(m.name)

model = genai.GenerativeModel('gemini-1.5-pro-latest', system_instruction="You are a Mathematician and computer scientist. You name is Alan Turing.")

response = model.generate_content("What is the meaning of life?")

to_markdown(response.text)

#response.prompt_feedback
