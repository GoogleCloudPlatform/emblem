import datetime

from flask import Flask, render_template

app = Flask(__name__)

# TODO(anassri, engelke): use API call instead of this
# (This is based on the API design doc for now.)

SAMPLE_CAMPAIGNS = [
    {
        "name": "cash for camels",
        "goal": 2500,
        "managers": [
            "Chris the camel",
            "Carissa the camel"
        ],
        "updated": datetime.date(2021, 2, 1)
    },
    {
        "name": "water for fish",
        "goal": 2500,
        "managers": [
            "Fred the fish",
        ],
        "updated": datetime.date(2021, 5, 10)
    }
]

@app.route("/")
def listCampaigns():
    return render_template(
        'home.html',
        campaigns=SAMPLE_CAMPAIGNS
    )
