// ЛАБОРАТОРНАЯ 9. MONGODB

use('teterin-db');
db.restaurants.find().limit(1)

// Рестораны

// Найти в каждом районе ресторан с Итальянской
// с наименьшей оценкой
use('teterin-db')
db.restaurants.aggregate([
  {
    $match: {
      cuisine: "Italian"
    }
  },
  {
    "$unwind": "$grades"
  },
  {
    $group: {
      _id: { 'borough': '$borough' },
      name : { $first: '$name' },
      cuisine: { $first: '$cuisine' },
      minScore: { $min: '$grades.score' }
    }
  },
  {
    $project: 
    {
      _id: 0,
      borough: "$_id.borough",
      restaurant: '$name',
      cuisine: '$cuisine',
      score: '$minScore'
    }
  },
  {
    "$sort": { "borough": 1 } 
  }
])

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
db.restaurants.updateOne(
  {
    'restaurant_id' : '1201120112'
  }, 
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

use('teterin-db')
db.restaurants.find().limit(10)

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
        _id: "$year", 
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

// 2
// Какова средняя температура в году, если исключить 10 дней с самой 
// низкой температурой и 10 дней с самой высокой?
use('teterin-db');
db.weather.aggregate(
  [
    {
      $group : 
      {
        _id: {
          year: "$year",
          month: "$month",
          day: "$day"
        },
        avg_temp: {
          $avg: '$temperature'
        },
      }
    }, 
    { 
      "$sort": { "avg_temp": 1 } 
    },
    {
      "$skip": 10
    },
    {
      "$sort": { "avg_temp": -1 } 
    },
    {
      "$skip": 10
    },
    {
      $group: 
      {
        _id: '$_id.year', 
        temperature: { $avg: '$avg_temp'} 
      }
    }
  ]  
)

// 3
// Найти первые 10 записей с самой низкой погодой, когда дул ветер 
// с юга и посчитайте  среднюю температуры для этих записей
use('teterin-db');
db.weather.aggregate(
  [
    {
      $match: {
        "wind_direction": "Южный"
      }
    },
    {
      "$sort": { "temperature": 1 }
    },
    {
      "$limit": 10
    },
    {
      $group: {
        _id: "$year", 
        temperature: { $avg: '$temperature'} 
      }
    }
  ]
)

// 4
// Подсчитайте количество дней, когда шел снег. 
// (Будем считать снегом осадки, которые выпали,  
// когда температура была ниже нуля
use('teterin-db');
db.weather.aggregate(
  [
    {
      $match: {
        "temperature": { $lt: 0 }
      }
    },
    {
      $group: 
      {
        _id: {
          year: "$year",
          month: "$month",
          day: "$day"
        },
        count: { $sum: 1 }
      }
    },
    {
      $count: "count_days"
    }
  ]
)

// 5
// В течение зимы иногда шел снег, а иногда дождь. 
// Насколько больше (или меньше) выпало осадков в виде снега.
use('teterin-db');
db.weather.aggregate(
  [
    {
      $match: {
        "month": { $in: [1, 2, 12] }
      }
    },
    {
      $project: {
        _id: {
          year: "$year",
          month: "$month",
          day: "$day"
        },
        lessThan0: { 
          $cond: [ { $lt: ["$temperature", 0 ] }, 1, 0]
        },
        moreThan0: { 
          $cond: [ { $gt: [ "$temperature", 0 ] }, 1, 0]
        }
      }
    },
    {
      $group: {
          _id: "$_id.year",
          countLessThan0: { $sum: "$lessThan0" },
          countMoreThan0: { $sum: "$moreThan0" }
      }
    },
    {
      $project: 
      {
        _id: "$_id", 
        temperature_sub: { $subtract: ["$countLessThan0", "$countMoreThan0"] }
      }
    }
  ]
)

// 6
// Какова вероятность того что в ясный день выпадут осадки? 
// (Предположим, что день считается ясным, если ясная погода 
// фиксируется более чем в 75% случаев)
use('teterin-db');
db.weather.aggregate(
  [
    {
      $project: {
        _id: {
          year: "$year",
          month: "$month",
          day: "$day"
        },
        CL: {
          $cond: [ { $eq: ["$code", 'CL'] }, 1, 0]
        },
        notCL: {
          $cond: [ { $ne: ["$code", 'CL'] }, 1, 0]
        }
      }
    },
    {
      $group: {
        _id: '$_id',
        sumCL: { $sum: "$CL" },
        sumNotCL: { $sum: "$notCL" }
      }
    },
    {
      $project: {
        _id: "$_id",
        perc: { $multiply: [{$divide: ["$sumCL", { $add: ['$sumCL', '$sumNotCL'] }]}, 100] },
        weathertype: {
          $cond: { 
            if: { $gte: [{ $multiply: [{$divide: ["$sumCL", { $add: ['$sumCL', '$sumNotCL'] }]}, 100] } , 75 ] }, 
            then: 'Вероятно погода будет ясная', 
            else: 'Вероятно погода будет пасмурная' 
          }
        }
      }
    },
    // {
    //   $group: {
    //     _id: { year: '$_id.year' },
    //     S: { $sum: { $cond: [ { $eq: ["$weathertype", 'S'] }, 1, 0] } },
    //     R: { $sum: { $cond: [ { $eq: ["$weathertype", 'R'] }, 1, 0] } }
    //   }
    // }
  ]
)

// 7
// Увеличьте температуру на один градус при каждом измерении 
// в нечетный день во время зимы.  На сколько градусов 
// изменилась средняя температура?
use('teterin-db');
db.weather.aggregate([
  {
    $project: {
      _id: '$year',
      temperature: 1,
      tempWithNotEvenDays: {
        $cond: {
          if: {
            $and: [
              { "month": { $in: [1, 2, 12] } },
              { $eq: [{ $mod: ['$day', 2] }, 1]}
            ]
          },
          then: { $add: ['$temperature', 1] },
          else: { $add: ['$temperature', 0] }
        }
      }
    }
  },
  {
    $group: {
      _id: '$_id',
      temperature: { $avg: '$temperature' },
      withNotEvenTemperature: { $avg: '$tempWithNotEvenDays' }
    }
  },
  {
    $project: {
      _id: 1,
      sub: {
        $round: [
          { $subtract: [
            '$withNotEvenTemperature',
            '$temperature'
          ] },
          5
        ]
      }
    }
  }
]);


use('teterin-db');
db.weather.find().limit(10)