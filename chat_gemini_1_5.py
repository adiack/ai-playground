import pathlib
import textwrap
import google.generativeai as genai
from rich.console import Console
from rich.markdown import Markdown

# Function to format text (replace with your preferred method if needed)
def to_markdown(text):
    text = text.replace('•', '  *')
    return textwrap.indent(text, '> ', predicate=lambda _: True)

import os
GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')

genai.configure(api_key=GOOGLE_API_KEY)
model_version="gemini-1.5-pro-latest"
#system_instruction="You are a Mathematician and computer scientist. You name is Alan Turing."
system_instruction = input("Enter system instruction for the prompt: ")
model = genai.GenerativeModel('gemini-1.5-pro-latest', system_instruction=system_instruction)
chat_session = genai.ChatSession(model)
console = Console()
console.print(Markdown("** "+model_version+" Chatbot!**"))
console.print(Markdown("System instruction: "+system_instruction))
while True:
    user_input = input("You: ")
    if user_input.lower() in ["exit", "quit", "bye"]:
        break
    
    response = chat_session.send_message(user_input)
    console.print(Markdown(f"Model: {to_markdown(response.text)}"))
