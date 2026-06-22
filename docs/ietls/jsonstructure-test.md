# JSON Structure — `formated/test/`

## Source file

`formated/test/1-1-1.json`

## What information it holds

The reading passage text with word-level tokenisation. Each sentence is broken into individual word tokens, and sentences that are relevant to a question include `selected_words`, `reason`, `question_ids`, and an `explain` field showing the answer rationale.

## Tree structure

```
{
  "test_text": {
    "title": "A spark, a flint: How fire leapt to life",
    "article": {
      "title": "A spark, a flint: How fire leapt to life",
      "footer": [],
      "glossary": [],
      "sections": [
        {
          "items": [
            {
              "type": "",
              "items": [
                {
                  "items": [
                    {
                      "sentence_gid": "a1t1r1_0-0-0-0",   // unique sentence ID
                      "sentence_raw": "To early man, fire was...",  // original sentence text
                      "sentence_uid": 1,                   // sentence sequence number
                      "selected_words": "To,early,man,...", // comma-separated words relevant to a question
                      "reason": true,                      // if true, this sentence has an explanation
                      "question_ids": [1],                 // question numbers this sentence relates to
                      "explain": "Q1: ...",                // explanation text
                      "items": [                           // word-level tokens
                        { "type": "word", "span": "To", "word_gid": "a1t1r1_0-0-0-0_0" },
                        { "type": "",      "span": " ",  "word_gid": "a1t1r1_0-0-0-0_1" },
                        { "type": "word", "span": "early", "word_gid": "a1t1r1_0-0-0-0_2" },
                        ...
                      ]
                    }
                  ]
                }
              ],
              "title": ""
            }
          ]
        }
      ]
    }
  }
}
```

## How to access

```python
import json

with open("formated/test/1-1-1.json") as f:
    data = json.load(f)

title = data["test_text"]["title"]
article_title = data["test_text"]["article"]["title"]
sections = data["test_text"]["article"]["sections"]

for section in sections:
    for item in section["items"]:
        for paragraph in item["items"]:
            for sentence in paragraph["items"]:
                raw = sentence["sentence_raw"]
                tokens = sentence["items"]       # list of {type, span, word_gid}
                if "explain" in sentence:
                    print(sentence["explain"])
```

## What this data could serve

- Render the full reading passage with highlighted words
- Build interactive reading exercises where users click on words to answer questions
- Show question explanations tied to specific sentences
- Display word-level annotations (glossary-style)
