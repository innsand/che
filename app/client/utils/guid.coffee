#### *module* utils/guid
#
#---
# Модуль для генерации уникального id в формате UUID.
#
# (по-настоящему глобальным он не является,
#  на разных машинах может повторятся)
# 

define [], ->
  S4 = ->
    Math.floor(Math.random() * 0x10000).toString 16

  ->
    S4() + S4() + "-" +
    S4() + "-" +
    S4() + "-" +
    S4() + "-" +
    S4() + S4() + S4()