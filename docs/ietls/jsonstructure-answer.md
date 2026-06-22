# JSON Structure — `formated/answer/`

## Source file

`formated/answer/1-1.json`

## What information it holds

The correct answers for all four IELTS sections (listening, reading, writing, speaking) for a given test. Also includes the user's submitted answer and whether it was judged correct.

## Tree structure

```
{
  "listening": [                      // Listening section answers
    {
      "question_id": "1",
      "user_answer": null,           // user's submitted answer (null if unanswered)
      "judgement": false,            // true = correct, false = incorrect
      "correct_answer": "A"          // the correct answer
    },
    {
      "question_id": "2",
      "user_answer": null,
      "judgement": false,
      "correct_answer": "C"
    },
    ...
  ],
  "reading": [                       // Reading section answers
    {
      "question_id": "1",
      "user_answer": null,
      "judgement": false,
      "correct_answer": "E"
    },
    ...
  ],
  "writing": [                       // Writing section (no judgement, only band score)
    {
      "question_id": "1",
      "user_answer": "",
      "band_score": "0.0"
    },
    {
      "question_id": "2",
      "user_answer": "",
      "band_score": "0.0"
    }
  ],
  "speaking": [                      // Speaking section (no judgement, only band score)
    {
      "question_id": "1",
      "user_answer": [],
      "band_score": "0.0"
    },
    {
      "question_id": "2",
      "user_answer": [],
      "band_score": "0.0"
    },
    {
      "question_id": "3",
      "user_answer": [],
      "band_score": "0.0"
    }
  ]
}
```

### Field notes

| Field | Type | Description |
|-------|------|-------------|
| `question_id` | string | Question number |
| `user_answer` | string / null / array | The answer submitted by the user |
| `judgement` | boolean | Correctness flag (listening & reading only) |
| `correct_answer` | string | The correct answer; multiple accepted values separated by `\|` |
| `band_score` | string | Band score (writing & speaking only) |

## How to access

```python
import json

with open("formated/answer/1-1.json") as f:
    data = json.load(f)

for section_name in ["listening", "reading", "writing", "speaking"]:
    for item in data[section_name]:
        qid = item["question_id"]
        correct = item["correct_answer"]
        user = item.get("user_answer")
        if "judgement" in item:
            print(f"{section_name} Q{qid}: correct={correct}, user={user}, judgement={item['judgement']}")
        if "band_score" in item:
            print(f"{section_name} Q{qid}: band={item['band_score']}")
```

## What this data could serve

- Display correct answers alongside user answers for review
- Calculate scores per section
- Show answer variants (pipe-separated alternatives)
- Build a practice test review UI
