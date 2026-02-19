# Changelog

All notable changes to Nebula Discord Bot will be documented in this file.

## [1.1.0] - 2026-02-19

### Changed
- **BREAKING**: Updated OpenAI library to version 1.12.0+ (from 0.28.x)
- Migrated from `openai.ChatCompletion.acreate()` to new `AsyncOpenAI` client structure
- Updated `ai_handler.py` to use `AsyncOpenAI` client with proper async handling
- Improved response handling for new OpenAI API structure
- All code and comments are now in English

### Migration Guide from 0.28.x to 1.12.0+

If you're upgrading from an older version:

1. **Update dependencies:**
   ```bash
   pip install --upgrade openai>=1.12.0
   ```

2. **Changes in code:**
   - Old: `openai.ChatCompletion.acreate()`
   - New: `AsyncOpenAI().chat.completions.create()`

3. **Response structure:**
   - Old: `response.choices[0].message`
   - New: `response.choices[0].message` (same structure, but obtained differently)

4. **Client initialization:**
   ```python
   # Old way
   openai.api_key = "key"
   openai.base_url = "url"
   
   # New way
   client = AsyncOpenAI(
       api_key="key",
       base_url="url"
   )
   ```

### Technical Details

- The new OpenAI client provides better type hints and error handling
- Async operations are now more explicit with `AsyncOpenAI` client
- Custom base URLs (like Liara.ir) are fully supported
- All tool calls and function calling work exactly the same way

### Compatibility

- ✅ Works with OpenAI API
- ✅ Works with OpenAI-compatible APIs (Azure, Liara.ir, etc.)
- ✅ Maintains all existing functionality
- ✅ No changes needed in database or other cogs

## [1.0.0] - 2026-02-19

### Added
- Initial release of Nebula Discord Bot
- AI-powered conversations with GPT-4
- 400k token memory management
- Admin tools (kick, ban, create channels, user activity)
- Google Custom Search integration
- SQLite database with 4 tables
- Comprehensive documentation

### Features
- Conversation memory with automatic reset
- User identification by display name
- Reply context awareness
- Message splitting for long responses
- Admin action logging
- Memory usage tracking commands
