//
//  Category.swift
//  BombGame
//
//  Created by Марина on 09.08.2023.
//

import Foundation
import UIKit

struct Category {
  var name: String
  var questions: [String]
}

enum GameState {
  case idle
  case playing
  case paused
}

class DataManager {
  static let shared = DataManager()
  var arrSelectedCategories = [String]()
  var arrSelectedIndex = [IndexPath]()

  var categories = [
    Category(name: "О разном", questions: [
      "Назовите марку машины",
      "Назовите  вид траспорта",
      "Назовите любимую еду на завтрак",
      "Назовите домашнее животное",
      "Назовите характеристику своего ноутбука",
      "Назовите любимую комедию",
      "Назовите героя из Гарри Поттера",
      "Назовите любимый сериал",
      "Назовите любимый напиток",
      "Назовите океан",
      "Назовите женское имя на букву М",
      "Назовите любимый предмет в школе",
      "Назовите любимый предмет в институте",
      "Назовите телеканал",
      "Назовите ягоду"]),
    Category(name: "Cпорт и Хобби", questions: [
      "Назовите любимую книгу",
      "Расскажите,чем займетесь в выходной",
      "Назовите спортсмена, выступающего на Олимпийский играх",
      "Назовите фигуристку",
      "Назовите футболиста ",
      "Назовите любимого музыкального исполнителя",
      "Назовите любимый телеканал",
      "Назовите любимый канал на YouTube",
      "Расскажите за кем следите в Инстаграм",
      "Назовите любимого автора из школьной литературы",
      "Назовите вид спорта",
      "Назовите мультик своего детства",
      "Назовите любимую игру на улице из детства",
      "Назовите хобби ",
      "Назовите любимый фильм"]),
    Category(name: "Про Жизнь", questions: [
      "Назовите пункт для классного утра",
      "Назовите пункт для  идеального вечер",
      "Расскажите как вести здоровый образ жизни",
      "Расскажите как повысить продуктивность",
      "Назовите сколько часов вы в среднем спите",
      "Назовите любимую еду на обед",
      "Назовите любимый ресторан в Москве",
      "Назовите любимое место отдыха заграницей",
      "Назовите свое домашнее животное",
      "Назовите ингредиент сладкого пирога",
      "Назовите свой любимый цветок",
      "Назовите вредную привычку",
      "Назовите любимый цвет",
      "Назовите имя классной руководительницы",
      "Назовите ВУЗ, который закончили"]),
    Category(name: "Знаменитости", questions: [
      "Назовите российскую актрису кино",
      "Назовите президента России",
      "Назовите певицу",
      "Назовите бойс-бенд",
      "Назовите писателя",
      "Назовите блогера",
      "Назовите любимого режиссера кино",
      "Назовите фильмы, где снимался Александр Петров",
      "Назовите комика",
      "Назовите политического деятеля",
      "Назовите спорстмена",
      "Назовите человека из списка Форбс",
      "Назовите популярного человека из IT мира",
      "Назовите ведущего",
      "Назовите шеф-повара"]),
    Category(name: "Искусство и Кино", questions: [
      "Назовите факт о Гарри Поттере",
      "Назовите поэтов Серебряного века",
      "Назовите жанр кино",
      "Назовите картину Ван Гога",
      "Назовите натюрморт ",
      "Назовите боевик",
      "Назовите фильм Тарантино",
      "Назовите детективный фильм",
      "Назовите книгу Агаты Кристи",
      "Процитируйте Пушкина",
      "Назовите животного из Африки",
      "Назовите героя из \"Войны и мир\"",
      "Назовите жанр живописи",
      "Назовите художника",
      "Назовите любимую книгу"]),
    Category(name: "Природа", questions: [
      "Назовите пресноводное озеро в России",
      "Назовите породу кошки",
      "Назовите млекопитающее",
      "Назовите животное с четырьмя лапами",
      "Назовите морского животного ",
      "Назовите насекомого",
      "Назовите птицу",
      "Назовите динозавра",
      "Назовите вымирающее животное",
      "Назовите животного из Антарктики",
      "Назовите животного из Африки",
      "Назовите цветок",
      "Назовите вид возобновляемой энергии",
      "Назовите ягоду",
      "Назовите дерево"
    ])]

  let categoryNames = [String]()

  let arrayFon = ["Мелодия 1", "Мелодия 2", "Мелодия 3"]
  let arrayTick = ["Таймер 1", "Таймер 2", "Таймер 3"]
  let arrayExplosion = ["Взрыв 1", "Взрыв 2", "Взрыв 3"]

  let punishments = [
    "Игрок должен прыгать на одной ноге вокруг стола перед каждым ходом",
    "Игрок должен петь свой следующий ответ на мелодию известной песни",
    "Игрок должен выполнить 10 приседаний перед каждым своим ходом",
    "Игрок должен говорить на заданном акценте весь следующий раунд",
    "Игрок должен повторять каждую свою фразу дважды перед тем, как задать вопрос",
    "Игрок должен носить на себе необычный предмет одежды, например, шляпу, перчатки или очки, весь следующий раунд",
    "Игрок должен сделать веселый танец перед каждым своим ходом",
    "Игрок должен писать свои ответы на бумаге и передавать их ведущему, чтобы он прочитал их вслух",
    "Игрок должен носить на себе временную татуировку в течение следующего часа",
    "Игрок должен ответить на следующий вопрос, используя только жесты и мимику, без слов"
  ]

  func getRandomPunishment() -> String {
    punishments.randomElement() ?? "В следующем раунде после каждого ответа хлопать в ладоши"
  }
}
