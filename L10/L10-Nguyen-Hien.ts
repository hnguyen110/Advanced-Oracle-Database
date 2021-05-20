db.grades.find({}, {"student_id": 1, "class_id": 1, "_id": 0}).sort({"student_id": -1, "class_id": 1});
db.grades.aggregate([
    {$project: {
        "_id": 0,
        "student_id": 1,
        "class_id": 1,
    }},
    {$sort: {"student_id": -1, "class_id": 1}}
]);

db.grades.find({"student_id": {$gte: 10, $lte: 12}}, {"student_id": 1, "class_id": 1, "_id": 0}).sort({"student_id": -1, "class_id": 1});
db.grades.aggregate([
    {$project: {
        "_id": 0,
        "student_id": 1,
        "class_id": 1,
    }},
    {$match: {
        "student_id": {$gte: 10, $lte: 12}
    }},
    {$sort: {"student_id": -1, "class_id": 1}}
]);

db.grades.distinct("class_id");
db.grades.aggregate([
    {$group: {_id: "$class_id"}},
    {$sort: {_id: 1}}
]);

db.grades.find({"scores.score": {$gt: 99.00}}, {"student_id": 1, "class_id": 1, "_id": 0}).sort({"student_id": -1, "class_id": 1});
db.grades.aggregate([
    {$match: {
        scores: {$elemMatch: {score: { $gt:99 }}}}
    },
    {$project: {
        "_id": 0,
        "student_id": 1,
        "class_id": 1,
    }},
    {$sort: {"student_id": -1, "class_id": 1}}
]);

db.grades.aggregate([
    {$project: {
        "_id": 0,
        "student_id": 1,
        "class_id": 1
    }},
    {$sort: {"student_id": -1, "class_id": 1}}
]);

db.grades.aggregate([
{$group: {
    _id: "$student_id",
    max_class_id: {$max: "$class_id"},
    min_class_id: {$min: "$class_id"}
}},
{$sort: {"_id": 1}},
{$limit: 10}
]);

db.grades.aggregate([
    {$match: {
        student_id: 48,
         scores: {
            $elemMatch: {
                score: {$lt: 59},
                type: "exam"
            }
        }
    }},
    {$count: "failed_exams"}
]);