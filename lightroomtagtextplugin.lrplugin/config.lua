return {
--  MODEL = "mistralai/ministral-3-3b",
--  API_URL = "http://127.0.0.1:1234/v1/responses",
--  API_KEY = "1234",
  INSTRUCTIONS = [[
**Context**:
You're to generate tags that can help with both describing and contextualizing an image as well as enabling recall when searching an image library. Tags should be succinct and not hierarchical, with a bias towards single-word tags. For example, for an image of an airliner taxing after landing you might recommend tags such as:
```
a330, a330-300, aeropuerto, airbus, aircraft, airliner, airplane, airport, avión, blue sky, clouds, lufthansa, runway, takeoff, tarmac, taxi lights, taxiway, transportation, travel
```
**Instructions**:
- Receive the image and write comma-separated list of tags that describes its contents.
- Keep the tags factual and objective. Omit subjective details such as the mood of the image.
- Use nouns and adjetives, avoiding verbs or adverbs when possible.
- If a tag is central to the main subject of the image, also include the tag in Spanish. 
- Tags should be plaintext only using alphanumeric characters.
- Limit to 20 tags or fewer, with a bias toward fewer while still succinctly describing the image.
- IMPORTANT: Output _only_ a single comma-delimited list of tags, with no additional text or formatting.
  ]]
}
