import requests
import json
import pandas as pd
import numpy as np

min_group_size = 4



players = ["dama_x_rey",
            "Akristjansson",
            "Airini_H",
            "fwcj68",
            "RabbieR",
            "jcarmody",
            "seandcosta",
            "UpGoerFive",
            "FunnyLikeAClown",
            "RMNL",
            "michielvdg",
            "Callosum",
            "omertil",
            "momor",
            "DrRickinCt",
            "Hepatiaaa",
            "R0B-W",
            "ssyx",
            "NameGoesInHere",
            "fritsj",
            "ButterPecan",
            "wizzywop",
            "ysgwydd",
            "Sneaky_Attack",
            "nairwolf",
            "Dadievid",
           "RAnzalone",
            "codydegen",
           "Walfie",
            "Mag1c1an01",
           "baberle",
            "nairwolf"]

opening_line = ("\nWelcome to your Off-Season Quads group channel! You can schedule games here (or in DM's), keep track "
                "of scores etc. This is your own channel so use it how you wish.\n\n")
closing_line = "\nRemember to post your games in #off-season-quads-games so that others can watch. Enjoy your games!\n"
rules = "Rules, Pairings & Info: https://bit.ly/3tckfPM\n"

my_dict = {}

for user in players:
    API = 'https://lichess.org/api/user/' + user + '/perf/classical'

    # Connect to an API
    response = requests.get(API)
    # Get the data from API
    data = response.text
    # Parse the data into JSON format
    parse_json = json.loads(data)
    # Extract the data
    my_dict[user] = parse_json['perf']['glicko']['rating']

series = pd.Series(my_dict).sort_values(ascending=False)

groups = (np.array_split(series, round(len(series) / min_group_size)))

for group in groups:
    message = opening_line
    topic = rules
    for index, item in enumerate(group):
        message += 'Board %d: @%s\n' % (index + 1, group.index[index])
        topic += 'B%d: %s ' % (index + 1, group.index[index])
    message += closing_line
    print(message)
    print(topic)
