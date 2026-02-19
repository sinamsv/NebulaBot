# OpenAI Library Migration Guide

## Migrating from OpenAI 0.28.x to 1.12.0+

This guide explains the changes made to support the new OpenAI library structure (version 1.12.0+).

### Overview

The OpenAI Python library underwent a major refactor in version 1.0.0, introducing breaking changes. Nebula bot has been updated to use the new structure for better performance, type safety, and error handling.

## What Changed?

### 1. Import Statement

**Old (0.28.x):**
```python
import openai
```

**New (1.12.0+):**
```python
from openai import AsyncOpenAI
```

### 2. Client Initialization

**Old (0.28.x):**
```python
openai.api_key = os.getenv('OPENAI_API_KEY')
openai.base_url = os.getenv('OPENAI_BASE_URL')
```

**New (1.12.0+):**
```python
self.openai_client = AsyncOpenAI(
    api_key=os.getenv('OPENAI_API_KEY'),
    base_url=os.getenv('OPENAI_BASE_URL')
)
```

### 3. API Calls

**Old (0.28.x):**
```python
response = await openai.ChatCompletion.acreate(
    model="gpt-4-turbo-preview",
    messages=messages,
    tools=tools,
    temperature=0.7,
    max_tokens=2000
)
```

**New (1.12.0+):**
```python
response = await self.openai_client.chat.completions.create(
    model="gpt-4-turbo-preview",
    messages=messages,
    tools=tools,
    temperature=0.7,
    max_tokens=2000
)
```

### 4. Response Handling

**Old (0.28.x):**
```python
response_message = response.choices[0].message

# Check for tool calls
if hasattr(response_message, 'tool_calls') and response_message.tool_calls:
    # Process tools
```

**New (1.12.0+):**
```python
choice = response.choices[0]
response_message = choice.message

# Check for tool calls (more explicit)
if response_message.tool_calls:
    # Process tools
```

## Installation Steps

### Step 1: Update Dependencies

```bash
pip install --upgrade openai>=1.12.0
```

Or update your `requirements.txt`:
```txt
openai>=1.12.0
```

Then run:
```bash
pip install -r requirements.txt
```

### Step 2: Verify Installation

Check your OpenAI version:
```bash
python -c "import openai; print(openai.__version__)"
```

Should output: `1.12.0` or higher

### Step 3: Test the Bot

Run the bot and send a test message:
```bash
python bot.py
```

In Discord:
```
@Nebula hello, test message
```

## Common Migration Errors

### Error 1: "openai.ChatCompletion is no longer supported"

**Problem:**
```
You tried to access openai.ChatCompletion, but this is no longer 
supported in openai>=1.0.0
```

**Solution:**
Update to the new code structure. The bot files provided are already updated.

### Error 2: AttributeError with AsyncOpenAI

**Problem:**
```python
AttributeError: 'AsyncOpenAI' object has no attribute 'ChatCompletion'
```

**Solution:**
Use `client.chat.completions.create()` instead of `client.ChatCompletion.acreate()`

### Error 3: Response structure mismatch

**Problem:**
Response handling fails because of changed structure

**Solution:**
Access response with: `response.choices[0].message` (same as before)

## Key Benefits of New Version

### 1. Better Type Hints
The new library provides proper type hints for IDE autocomplete and type checking.

### 2. Explicit Client
Using an explicit client makes code more maintainable and testable.

### 3. Better Error Messages
More descriptive error messages help with debugging.

### 4. Async Support
Native async support with `AsyncOpenAI` for better performance in Discord bots.

### 5. Compatibility
Works with all OpenAI-compatible APIs:
- Official OpenAI API
- Azure OpenAI
- Liara.ir (Iran)
- LocalAI
- Any OpenAI-compatible endpoint

## Custom Base URLs

The new version fully supports custom base URLs for OpenAI-compatible APIs:

**.env configuration:**
```env
OPENAI_BASE_URL=https://ai.liara.ir/api/YOUR_KEY/v1
```

**In code:**
```python
self.openai_client = AsyncOpenAI(
    api_key=api_key,
    base_url=base_url  # Your custom endpoint
)
```

## Testing Your Migration

### Test 1: Basic Conversation
```
@Nebula what's 2+2?
```
Expected: Bot responds with answer

### Test 2: Memory
```
@Nebula remember that my favorite color is blue
@Nebula what's my favorite color?
```
Expected: Bot remembers your preference

### Test 3: Search Tool
```
@Nebula search for latest AI news
```
Expected: Bot performs search and returns results

### Test 4: Admin Tools (if admin)
```
@Nebula check activity for @username
```
Expected: Bot shows user activity stats

## Rollback (If Needed)

If you need to rollback to the old version temporarily:

```bash
pip install openai==0.28.1
```

However, note that you'll need to use the old code structure. It's recommended to upgrade instead.

## Getting Help

If you encounter issues:

1. Check the error message in console
2. Verify OpenAI version: `pip show openai`
3. Ensure API keys are correct in `.env`
4. Check the CHANGELOG.md for recent updates
5. Review the DOCUMENTATION.md for detailed info

## Additional Resources

- [OpenAI Python Library GitHub](https://github.com/openai/openai-python)
- [Official Migration Guide](https://github.com/openai/openai-python/discussions/742)
- [OpenAI API Documentation](https://platform.openai.com/docs)

---

**Note:** All code in the Nebula bot repository is already updated to use OpenAI 1.12.0+. You just need to install the correct version with `pip install -r requirements.txt`.
