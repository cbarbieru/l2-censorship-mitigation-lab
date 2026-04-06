export const pastElections =
    {
        "2020": {
            "Parliamentary elections": {
                "Senate": "https://rezultatevot.ro/embed/112/results",
                "Chamber of deputies": "https://rezultatevot.ro/embed/113/results"
            },
            "Local elections": {
                "Mayor": "https://rezultatevot.ro/embed/95/results",
                "County council president": "https://rezultatevot.ro/embed/96/results",
                "Local council": "https://rezultatevot.ro/embed/97/results",
                "County council": "https://rezultatevot.ro/embed/97/results",
                "Mayor-special elections": "https://rezultatevot.ro/embed/99/results"
            }
        },
        "2019": {
            "Presidential elections": {
                "Second Round": "https://rezultatevot.ro/embed/2/results",
                "First Round": "https://rezultatevot.ro/embed/3/results"
            },
            "European parliament": "https://rezultatevot.ro/embed/4/results",
            "Referendum": {
                "Interzicerea Infractiunilor": {
                    title: "Sunteți de acord cu interzicerea adoptării de către Guvern a ordonanțelor de urgență în domeniul infracțiunilor, pedepselor și al organizării judiciare și cu extinderea dreptului de a ataca ordonanțele direct la Curtea Constituțională?",
                    url: "https://rezultatevot.ro/embed/5/results"
                },
                "Interzicerea Amnistiei": {
                    title: "Sunteți de acord cu interzicerea amnistiei și grațierii pentru infracțiuni de corupție?",
                    url: "https://rezultatevot.ro/embed/6/results"
                }
            }
        },
        "2018": {
            "Referendum": {
                "Revizuire Constitutie": {
                    title: "Sunteți de acord cu Legea de revizuire a Constituției României în forma adoptată de Parlament?",
                    url: "https://rezultatevot.ro/embed/7/results"
                }
            }
        }
    };

export const getPastElectionUrl = (year, electionType, election) => {
    if (election) {
        if (typeof pastElections[year][electionType][election] == "object") {
            return pastElections[year][electionType][election].url;
        } else {
            return pastElections[year][electionType][election];
        }
    } else {
        return pastElections[year][electionType];
    }
};

export const getPastElectionTitle = (year, electionType, election) => {
    if (election) {
        if (typeof pastElections[year][electionType][election] == "object") {
            return pastElections[year][electionType][election].title;
        } else {
            return election;
        }
    } else {
        return electionType;
    }
};
