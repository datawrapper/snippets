needs(dplyr, tidyr, readr, jsonlite)

trump_ratings <- read_csv('https://projects.fivethirtyeight.com/trump-approval-data/approval_topline.csv') %>%
  filter(subgroup=='All polls') %>%
  mutate(date=as.Date(modeldate, format='%m/%d/%Y'),
         approve=as.numeric(approve_estimate),
         disapprove=as.numeric(disapprove_estimate)) %>%
  select(date, approve, disapprove, president)

ratings <- read_json('https://projects.fivethirtyeight.com/trump-approval-data/historical-approval.json', T) %>%
  mutate(date=as.Date(date),
         approve=as.numeric(approve_estimate),
         disapprove=as.numeric(disapprove_estimate))%>%
  select(date, approve, disapprove, president) %>%
  bind_rows(trump_ratings) %>%
  group_by(date=as.Date(paste0(format(date, '%Y-%m'),'-01'))) %>%
  summarise(president=last(president), approve=mean(approve), disapprove=mean(disapprove))

ratings %>%
  select(date, president, approve) %>%
  filter(date>='1961-02-01') %>%
  mutate(president=as.factor(as.character(president))) %>%
  spread(president, approve) %>%
write_tsv('ratings.csv', na = '')
