# bot.py
import os
import requests
import asyncio
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes

BOT_TOKEN = os.getenv("8244755457:AAFAQNf1oMuBiGyEe_on6Fi_rXqDcKIdRjg")
VT_KEY = os.getenv("43d08a2bafc5bab1988ca1e115cf37ce3b8b1d3effddf24272187e0984764bdd")
VT_SCAN_URL = "https://www.virustotal.com/api/v3/urls"
VT_REPORT_URL = "https://www.virustotal.com/api/v3/analyses/{}"

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    await update.message.reply_text(
        "Salom! Men *PhishGuard* botman\n"
        "Menga shubhali link yubor — men uni tekshiraman!\n\n"
        "Misol: `https://fake-bank.uz`", 
        parse_mode="Markdown"
    )

async def check_link(update: Update, context: ContextTypes.DEFAULT_TYPE):
    url = update.message.text.strip()
    if not url.startswith(("http://", "https://")):
        await update.message.reply_text("Iltimos, to‘g‘ri URL yuboring!")
        return

    msg = await update.message.reply_text("Tekshirilmoqda... ⏳")

    headers = {"x-apikey": VT_KEY}
    try:
        # 1. URLni yuborish
        res = requests.post(VT_SCAN_URL, data={"url": url}, headers=headers)
        analysis_id = res.json()["data"]["id"]

        # 2. Natijani kutish
        for _ in range(12):
            await asyncio.sleep(5)
            report = requests.get(VT_REPORT_URL.format(analysis_id), headers=headers).json()
            if report["data"]["attributes"]["status"] == "completed":
                break

        stats = report["data"]["attributes"]["stats"]
        total = sum(stats.values())
        risk = stats["malicious"] + stats["suspicious"]

        if risk == 0:
            result = "XAVFSIZ"
        elif risk <= 2:
            result = "SHUBHALI"
        else:
            result = "XAVFLI"

        await msg.edit_text(
            f"*Natija:* {result}\n\n"
            f"Xavfli: {stats['malicious']}\n"
            f"Shubhali: {stats['suspicious']}\n"
            f"Xavfsiz: {stats['harmless']}\n"
            f"Jami: {total}\n\n"
            f"Ko‘proq: [VirusTotal](https://www.virustotal.com/gui/url/{res.json()['data']['id']})",
            parse_mode="Markdown", disable_web_page_preview=True
        )
    except:
        await msg.edit_text("Xato yuz berdi. Keyinroq urinib ko‘ring.")

def main():
    app = Application.builder().token(BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, check_link))
    print("PhishGuard bot ishga tushdi...")
    app.run_polling()

if __name__ == "__main__":
    main()
