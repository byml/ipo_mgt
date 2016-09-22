# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

broker_zszq = Broker.create(id: 1, code: 'zszq', name: '招商证券') 
broker_gjzq = Broker.create(id: 2, code: 'gjzq', name: '国金证券') 
broker_pazq = Broker.create(id: 3, code: 'pazq', name: '平安证券') 
broker_dgzq = Broker.create(id: 4, code: 'pazq', name: '东莞证券') 

stakeholder_byml = Stakeholder.create(id: 1, code: 'byml', name: 'lzy')
stakeholder_cexo = Stakeholder.create(id: 2, code: 'cexo', name: 'xxj')
stakeholder_maggie = Stakeholder.create(id: 3, code: 'maggie', name: 'lzj')
stakeholder_mum = Stakeholder.create(id: 4, code: 'mum', name: 'qfr')

account_info_byml_zszq = AccountInfo.create(id: 1, code: 'byml_zszq', broker: broker_zszq, stakeholder: stakeholder_byml)
account_info_byml_gjzq = AccountInfo.create(id: 2, code: 'byml_gjzq', broker: broker_gjzq, stakeholder: stakeholder_byml)
account_info_byml_pazq = AccountInfo.create(id: 3, code: 'byml_pazq', broker: broker_pazq, stakeholder: stakeholder_byml)
account_info_cexo_gjzq = AccountInfo.create(id: 4, code: 'cexo_gjzq', broker: broker_gjzq, stakeholder: stakeholder_cexo)
account_info_maggie_pazq = AccountInfo.create(id: 5, code: 'maggie_pazq', broker: broker_pazq, stakeholder: stakeholder_maggie)
account_info_mum_dgzq =  AccountInfo.create(id: 6, code: 'mum_dgzq', broker: broker_dgzq, stakeholder: stakeholder_mum)
