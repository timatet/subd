// ЛАБОРАТОРНАЯ 9. MONGODB

use('teterin-db')
db.restaurants.find().limit(1)

// Рестораны

// 1
// Выведите все документы коллекции Ресторан в формате: 
// restaurant_id, name, borough и cuisine, вывод  _id  для всех 
// документов исключить.
use('teterin-db');
db.restaurants.find(
  {

  },
  {
    'restaurant_id': 1,
    'name': 1, 
    'borough': 1, 
    'cuisine': 1,
    '_id': 0
  }
)

// 2
// Выведите  первые 5 ресторанов в алфавитном порядке, которые 
// находятся в районе Bronx
use('teterin-db');
db.restaurants.find(
  {
    'borough': "Bronx"
  },
  {
    'name': 1, 
    '_id': 0
  }
).sort({ name: 1 })
.limit(5)

// 3
// Найдите рестораны, которые набрали более 80, но менее 100 
// баллов
use('teterin-db');
db.restaurants.find( 
  {
    "grades.score": 
    {
      $gt: 80,
      $lt: 100
    }
  }, 
  {
    'name': 1, 
    'grades.score': 1,
    '_id': 0
  } 
)

// 4
// Найдите рестораны, которые не относятся к  типу кухни American, 
// получили оценку «А», не расположены  в районе Brooklyn.  Документ
// должен отображаться в соответствии с кухней в порядке убывания
use('teterin-db');
db.restaurants.find(
  {
    'cuisine': { $not: { $regex: 'American' } },
    'borough': { $not: { $regex: 'Brooklyn' } },
    'grades.grade': 'A'
  },
  {
    'restaurant_id': 1,
    'name': 1, 
    'borough': 1, 
    'cuisine': 1,
    'grades.grade': 1,
    '_id': 0
  }
).sort({ 'cuisine': -1 })

// 5
// Найдите идентификатор ресторана, название, район и кухню 
// для тех ресторанов, чье название начинается с первых 
// трех букв назвали <<Wil>>
use('teterin-db');
db.restaurants.find(
  {
    'name': { $regex: '^Wil.*' }
  },
  {
    'restaurant_id': 1,
    'name': 1, 
    'borough': 1, 
    'cuisine': 1,
    '_id': 0
  }
)

// 6
// Найдите  рестораны, которые относятся к району Bronx и 
// готовят American  или Chinese блюда
use('teterin-db');
db.restaurants.find(
  {
    'borough': 'Bronx',
    'cuisine': { $regex: 'Chinese|American' }
  },
  {
    'restaurant_id': 1,
    'name': 1, 
    'borough': 1, 
    'cuisine': 1,
    '_id': 0
  }
)

// 7
// Найдите идентификатор ресторана, название и оценки для тех 
// ресторанов, которые  «2014-08-11T00: 00: 00Z» набрали 
// 9 баллов за оценку А
use('teterin-db');
db.restaurants.find(
  {
    $and: [
      {'grades.date': ISODate('2014-08-11T00:00:00Z')},
      {'grades.score': { $eq: 9 }},
      {'grades.grade': 'A'}
    ]
  },
  {
    'restaurant_id': 1,
    'name': 1, 
    'grades': 1, 
    '_id': 0
  }
)

// 8
// В каждом районе посчитайте количество ресторанов по каждому 
// виду кухни. Документ должен иметь формат  
// borough, cuisine, count
use('teterin-db');
db.restaurants.aggregate( 
  [
    { 
      $group: { 
        _id:  { 
          "cuisine": "$cuisine",
          "borough": "$borough"
        }, 
        count: { $sum: 1 },
      }
    },
    {
      $project: 
      {
        _id: 0,
        borough: "$_id.borough",
        cuisine: "$_id.cuisine",
        count: "$count"
      }
    }
  ] 
)

// 9
// В  районе Bronx найдите ресторан с минимальной суммой 
// набранных баллов.
use('teterin-db');
db.restaurants.aggregate(
  [
    { 
      $unwind: "$grades" 
    },
    { 
      $group: { 
        '_id': { _id: '$_id', 'name': '$name', 'borough': 'Bronx' }, 
        'sum': { $sum: "$grades.score" },
      }
    }, 
    {
      $project: 
      {
        '_id': 0,
        'borough': "$_id.borough",
        'name': "$_id.name",
        'sum': "$sum"
      }
    },
    { 
      "$sort": { "sum": 1 } 
    },
    {
      "$limit": 1
    }
  ] 
)

// 10
// Добавьте в коллекцию свой любимый ресторан
use('teterin-db')
db.restaurants.insert(
  {
    "address": {
      "building": "40",
      "coord": [
        57.626557,
        39.873076
      ],
      "street": "Chaikovskogo street",
      "zipcode": "150040"
    },
    "borough": "Kirovskiy",
    "cuisine": "Coffee",
    "name": "Сoffee shop Morning",
    "restaurant_id": "1201120112"
  }
);

use('teterin-db')
db.restaurants.find({ 'restaurant_id': "1201120112" })

// 11
// В добавленном ресторане укажите информацию о 
// времени его работы
use('teterin-db')
db.restaurants.updateMany(
  {}, 
  { 
    $set: 
    {
      'working_time': {
        'openning_time': '7:30',
        'closing_time': '21:00'
      }
    }
  }
)

use('teterin-db')
db.restaurants.find({ 'restaurant_id': "1201120112" })

// 12
// Измените время работы вашего любимого ресторана
use('teterin-db')
db.restaurants.updateOne(
  { 
    'restaurant_id' : '1201120112'
  },
  { 
    $set: {
      'working_time.openning_time': '9:00'
    }
  }
);

use('teterin-db')
db.restaurants.find({ 'restaurant_id': "1201120112" })

// Погода

// 1
// Какова разница между максимальной и минимальной 
// температурой в течение года? 
use('teterin-db');
db.weather.aggregate(
  [
    {
      $group : 
      {
        _id:"$year", 
        min: { $min: "$temperature" }, 
        max: { $max: "$temperature" } 
      } 
    }, 
    {
      $project: 
      {
        _id: "$year", 
        temperature: { $subtract: ["$max", "$min"] }
      }
    }
  ]
)