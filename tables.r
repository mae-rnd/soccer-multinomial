library("dplyr")
library("sqldf")
location<-readline(prompt = "Data location: ")
matches <- readRDS(location)

#On pondère le poids des matches en fonction de leur date
matches$weight[matches$date<="2022-06-30"]<-1
matches$weight[matches$date>"2022-06-30" & matches$date<="2023-01-01"]<-2
matches$weight[matches$date>"2023-01-01" & matches$date<="2023-06-30"]<-3
matches$weight[matches$date>"2023-06-30" & matches$date<="2023-12-31"]<-4
matches$weight[matches$date>"2023-12-31" & matches$date<="2024-06-01"]<-5
matches$weight[matches$date>"2024-06-01"]<-6

#On calcule les moyennes pondérées qui serviront de variables explicatives au modèle
scored1 <- matches %>%
	group_by(home_team) %>%
	summarise(scored_home = weighted.mean(home_score, weight))

scored2 <- matches %>%
	group_by(away_team) %>%
	summarise(scored_away = weighted.mean(away_score, weight))

scored<-merge(x=scored1, y=scored2, by.x="home_team", by.y="away_team", ALL=TRUE)

colnames(scored)[1]="team"

conceded1 <- matches %>%
	group_by(home_team) %>%
	summarise(conceded_home = weighted.mean(away_score, weight))

conceded2 <- matches %>%
	group_by(away_team) %>%
	summarise(conceded_away = weighted.mean(home_score, weight))

conceded<-merge(x=conceded1, y=conceded2, by.x="home_team", by.y="away_team", ALL=TRUE)

colnames(conceded)[1]="team"

scored$scored<-rowMeans(scored[, c("scored_home", "scored_away")])

conceded$conceded<-rowMeans(conceded[, c("conceded_home", "conceded_away")])

lambda<-merge(x=scored[ , c("team","scored")], y=conceded[ , c("team","conceded")], by="team", ALL=TRUE)

#On crée la variable dépendante 
matches$outcome[matches$home_score==matches$away_score]<-0
matches$outcome[matches$home_score>matches$away_score]<-1
matches$outcome[matches$home_score<matches$away_score]<-2

#On utilise SQL pour l'introduire dans la table
matches<-sqldf('SELECT matches.*, lambda.scored AS scored_home FROM matches INNER JOIN lambda ON matches.home_team = lambda.team;')
matches<-sqldf('SELECT matches.*, lambda.scored AS scored_away FROM matches INNER JOIN lambda ON matches.away_team = lambda.team;')


matches<-sqldf('SELECT matches.*, lambda.conceded AS conceded_home FROM matches INNER JOIN lambda ON matches.home_team = lambda.team;')
matches<-sqldf('SELECT matches.*, lambda.conceded AS conceded_away FROM matches INNER JOIN lambda ON matches.away_team = lambda.team;')