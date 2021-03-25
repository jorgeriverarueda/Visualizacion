import pandas as pd
data = pd.read_csv('fifa18_clean.csv')
data['GK'] = (data['GK diving'] + data['GK handling'] + data['GK kicking'] + data['GK positioning'] + data['GK reflexes'])/5
data2 = data[['Name', 'GK', 'CB', 'CM', 'ST', 'RW', 'LB']]
data2.to_csv('radar2.csv', index=False)

