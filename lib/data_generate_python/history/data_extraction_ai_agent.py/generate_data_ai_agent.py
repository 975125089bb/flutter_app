from dataclasses import dataclass
from typing import Optional
import json
import uuid

import json
from openai import OpenAI
from Person import Person
from Prompt import Prompt

client = OpenAI(
    api_key=Prompt.API_KEY,
    base_url="https://api.deepseek.com",
)


def parse_person_info(API_KEY: str, text: str) -> Person:
    client = OpenAI(api_key=API_KEY, base_url="https://api.deepseek.com")

    response = client.chat.completions.create(
        model="deepseek-chat",
        messages=[
            {"role": "system", "content": Prompt.system_prompt},
            {"role": "user", "content": text},
        ],
        response_format={"type": "json_object"},
        stream=False,
    )

    json_data = json.loads(response.choices[0].message.content)
    print(json_data)
    # return Person(id=json_data.get("id", str(uuid.uuid4())), **json_data)
    return


text = """
- （编号499)

![WechatIMG2469](https://github.com/user-attachments/assets/67823fb4-e9c6-48d1-ac1e-ecc7520b92c2)

```
家乡：天津
居住地：埼玉县
性别：女
出生：1992年
身高：179.9
mbti：INFJ
星座：水瓶座
学历：日本高中+短大+本科
工作：跨境医疗·医疗翻译
年收：400+
签证：永驻申请中
未来规划：日本定居
家庭：父母都在国内，家庭合睦
性格：善良独立慢热，参考水瓶座
爱好：旅游，撸小动物（不仅限猫咪）
家有猫咪一只，拒绝任何理由的弃养。
希望对方：无不良嗜好，情绪稳定，乐观，做事有计划性
身高比我高即可，年收500+
```
"""


parse_person_info(API_KEY=Prompt.API_KEY, text=text)
