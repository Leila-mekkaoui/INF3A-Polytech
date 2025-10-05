#Mekkaoui leila python 3A
#projet python groupe 1

import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

Pays = ['France', 'Italy', 'India', 'Brazil', 'Australia']

# Créer les dates couvrant toutes les journées des années de 2021 à 2024
def creer_plage_date_2124():
    plage_de_dates = []
    date = datetime(2021, 1, 1)
    while date <= datetime(2024, 12, 31):
        plage_de_dates.append(date)
        date = date + timedelta(days=1)

    return plage_de_dates

#génere un tuple de (température, précipitation)
def temperature_et_precipitation():
    temperatures = np.random.randint(-10, 55)
    precipitations = np.random.randint(0, 350)

    return temperatures, precipitations

# met sous la forme d'un tableau pandas, la date, le pays, la température et la précipitation
def tableau_panda():
    ligne = []
    toutes_dates = creer_plage_date_2124() #recupère les dates

    for date in toutes_dates:
        for pays in Pays:
            t, p = temperature_et_precipitation() #recupère le tuple
            ligne.append((date, pays, t, p))

    #créer le tableau et ses colonnes
    tableau_pandas = pd.DataFrame(ligne, columns=['date', 'pays', 'temperature', 'precipitation'])

    return tableau_pandas

# met le tout dans un fichier csv
def genere_csv(contenue):
    try:
        ligne = contenue.to_csv(index=False).split('\n') #converti le tableau en csv et le sépare par ligne
        with open('data.csv', 'w') as df:
            for l in ligne:
                df.write(l) #écrit chaque ligne dans le fichier
    except Exception as e:
        print(f"Erreur lors de l'écriture du fichier: {e}")


def partie_1():
    #fonction pour faire la partie 1
    print("Début partie 1")
    content = tableau_panda()
    genere_csv(content)
    print("Partie 1 terminée, fichier créer")
    print()

############################## Partie 2
##Gestion des fichiers

#charge les fichiers
def charge_csv(fichier):
    try:
        contenue = pd.read_csv(fichier)
        contenue['date'] = pd.to_datetime(contenue['date']) #converti la colonne date en datetime

        return contenue
    except FileNotFoundError:
        print("Fichier non trouvé.")
        return None
    except Exception as e:
        print(f"Erreur lors de la lecture du fichier: {e}")
        return None


#tri et ne garde que les données entre date_debut et date_fin
def filtrer_date(dataframe, date_debut, date_fin):
    table = dataframe[(dataframe['date'] >= date_debut) & (dataframe['date'] <= date_fin)]
    return table

#tableau_sans_filtre=charge_csv("data.csv")
#tableau_avec_filtre=filtrer_date(tableau_sans_filtre, '2022-01-01', '2022-01-02')
#print (tableau_avec_filtre)


#calcule la moyenne le min et le max de temp ou precip
def stat_climatique(data, type_stat):
    #initialise les valeurs
    type_moy=0
    nbr_valeur=0 #pour la moyenne
    type_max=data[type_stat].iloc[0]
    type_min=data[type_stat].iloc[0]

    for t in data[type_stat]:
        type_moy += t
        nbr_valeur += 1

        if t > type_max:
            type_max = t
        if t < type_min:
            type_min = t

    type_moy = type_moy / nbr_valeur
    return type_moy, type_min, type_max

#calcule les stats climatiques moyenne par pays
def stat_clim_par_pays(data):
    #dico : {pays : (temp_moy, precip_moy) ... }
    stats_pays={}

    for pays in Pays:
        data_pays = data[data['pays'] == pays] #filtre les données pour le pays
        #calcule les stats
        temp_moy, temp_min, temp_max = stat_climatique(data_pays, "temperature")
        precip_moy, precip_min, precip_max = stat_climatique(data_pays, "precipitation")
        stats_pays[pays] = (temp_moy, precip_moy)

    return stats_pays

#cherche les 3 pays les plus chauds et les plus secs d'une période donnée
def gerer_stat(date_deb, date_fin):
    tableau_brut = charge_csv("data.csv")
    tableau_filtrer = filtrer_date(tableau_brut, date_deb, date_fin)

    stats_pays = stat_clim_par_pays(tableau_filtrer) #recupère les stats par pays

    #cherche les 3 pays les plus chauds dans cette période, puis sec
    pays_chaud = sorted(stats_pays.items(), key=lambda x: x[1][0], reverse=True)[:3] #trie par température moyenne décroissante
    pays_sec = sorted(stats_pays.items(), key=lambda x: x[1][1])[:3] #trie par précipitation moyenne croissante
    print("Les 3 pays les plus chauds sont :")
    for pays in pays_chaud:
        print(pays[0], ":", pays[1][0], "°C")

    print()

    print("Les 3 pays les plus secs sont :")
    for pays in pays_sec:
        print(pays[0], ":", pays[1][1], "mm")

    print()

    return


#cherche les stats qui "sortent de l'ordinaire" d'un dataframe
def analyse_precip(data):
    anomalies = {}
    for pays in Pays:

        data_pays = data[data['pays'] == pays].copy()
        data_pays['annee_mois'] = data_pays['date'].dt.to_period('M') #extrait l'année et le mois de la date

        #groupby mois et somme les précipitations
        data_mois = data_pays.groupby('annee_mois').agg({'precipitation': 'sum'})

        moyenne = data_mois['precipitation'].mean()
        ecart_type= data_mois['precipitation'].std()

        secheresse = moyenne - 2 * ecart_type
        frt_precip = moyenne + 2 * ecart_type

        #garde que les mois avec anomalies
        anomalies_mois = data_mois[ (data_mois['precipitation'] < secheresse) | (data_mois['precipitation'] > frt_precip)].copy()
        #rajoute une colonne pour pas écraser le dataframe de base
        anomalies_mois["anomalie"] = np.where(anomalies_mois['precipitation'] < secheresse, "secheresse", "precipitation forte")


        anomalies[pays] = anomalies_mois

    return anomalies

# mets en forme les anomalies trouvées
def mise_en_forme(dico):
    print("Anomalies de précipitations:")

    for pays, anomalies in dico.items():
        print(f"\n{pays}:")
        if anomalies.empty:
            print("Pas anomalie dans ce pays")
        else:
            for date, donnee in anomalies.iterrows():
                print(f"  {date}: {donnee['precipitation']} mm ({donnee['anomalie']})")

#fonction qui fait la patrie 2
def partie_2(date_deb, date_fin, fichier):
    print("Début partie 2")
    print()

    # avoir les 3 pays les plus chauds et les 3 pays les plus secs dans la période estivale de 2022
    gerer_stat(date_deb, date_fin)

    #voir les mois "anomalies" par pays
    data = charge_csv(fichier)
    dico = analyse_precip(data)
    mise_en_forme(dico)

    print()

# PARTIE 3 VISUALISATION

# variation quotidienne de la température pour un pays donné, regarde les "anomalies" et affiche le tout
def variation_quotidienne_par_pays(date_debut, date_fin, pays):
    data = charge_csv("data.csv")
    data = filtrer_date(data, date_debut, date_fin)

    data_pays = data[data['pays'] == pays] #filtre pour le pays
    #change l'ordre des colonnes pour simplifier l'utilisation de detecter_anomalie
    data_pays = data_pays[['date', 'temperature', 'pays']]

    #converti la date en string pour régler un soucis da comparaison et l'ajoute dans une colonne
    data_pays['annee_mois_str'] = data_pays['date'].astype(str)

    anomalie = detecter_anomalie(data_pays)
    couleurs = [] #prends des couleurs par "type" d'anomalie
    for date_str in data_pays['annee_mois_str']:
        if date_str in anomalie:
            if anomalie[date_str] == 'haut':
                couleurs.append('red')
            else:
                couleurs.append('blue')
        else:
            couleurs.append('gray')

    #pour les lignes
    plt.plot(data_pays['date'], data_pays['temperature'], color='gray')
    #pour les points colorés
    plt.scatter(data_pays['date'], data_pays['temperature'], marker="X", color=couleurs )

    plt.xlabel('Date')
    plt.ylabel('Valeur')
    plt.xticks(rotation=45) #pivoter les dates pour gagner de la place
    plt.title('Variation quotidienne de la température')

    plt.show()

# diagramme en barre des précipitations mensuelles pour un pays donné, regarde les "anomalies" et affiche le tout
def diagramme_barre(pays):
    data = charge_csv("data.csv")
    data = data[data['pays'] == pays].copy()

    data['annee_mois'] = data['date'].dt.to_period('M')
    #groupby mois et somme les précipitations, reset_index pour remettre annee_mois en colonne
    data_mois = data.groupby('annee_mois')['precipitation'].sum().reset_index()

    #converti la date en string pour régler un souci da comparaison et l'ajoute dans une colonne
    data_mois['annee_mois_str'] = data_mois['annee_mois'].astype(str)

    anomalie = detecter_anomalie(data_mois)

    couleurs = [] #prends des couleurs par "type" d'anomalie
    for date_str in data_mois['annee_mois_str']:
        if date_str in anomalie:
            if anomalie[date_str] == 'haut':
                couleurs.append('red')
            else:
                couleurs.append('blue')
        else:
            couleurs.append('gray')

    #faire le diagramme
    plt.bar(data_mois['annee_mois_str'], data_mois['precipitation'], color=couleurs)
    plt.xlabel('Date')
    plt.ylabel('Précipitations mensuelles (mm)')
    plt.title(f'Histogramme des précipitations mensuelles en {pays}')
    #afficher qu'une date sur 3 pour que ça ne s'écrase pas
    plt.xticks(data_mois['annee_mois'].astype(str)[::3], rotation=45)
    plt.show()

# detecte les anomalie
def detecter_anomalie(dataframe):
    #trier selon la seconde colonne (precip ou temp)
    noms_colonnes = dataframe.columns.tolist()
    index = noms_colonnes[0]
    donnees = noms_colonnes[1]

    #s'assure qu'on n'est pas de colonne inutile ua cas ou
    dataframe = dataframe[[index, donnees]]

    #faire les moyennes et ecart type
    moyenne = dataframe[donnees].mean()
    ecart_type = dataframe[donnees].std()

    #trouver les anomalies
    #seuil
    seuil_haut = moyenne + 1.2 * ecart_type #baisser le coeff pour plus de sensibilité
    seuil_bas = moyenne - 1.2 * ecart_type #coeff par défaut = 2

    anomalies = dataframe[(dataframe[donnees] > seuil_haut) | (dataframe[donnees] < seuil_bas)].copy()
    anomalies['seuil_depasse'] = np.where(anomalies[donnees] > seuil_haut, 'haut', 'bas')
    #renvoyer les dates avec leurs seuils dans un dico
    dico_anomalie = {str(row[index]).split()[0]: row['seuil_depasse'] for _, row in anomalies.iterrows()}

    return dico_anomalie

# fonction qui fait la partie 3
def partie3(date_deb, date_fin, pays):
    print("Début partie 3")
    variation_quotidienne_par_pays(date_deb, date_fin, pays)
    diagramme_barre(pays)

def jeu_test():
    print("Début du jeu de test")
    #partie 1
    partie_1()

    #partie 2
    partie_2('2022-06-01', '2022-08-31', "data.csv")

    #partie 3
    partie3('2022-01-01', '2022-01-31', "France")

    print("Fin du jeu de test")

    return

jeu_test()