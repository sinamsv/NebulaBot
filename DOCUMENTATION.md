# Nebula Bot - Detailed Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [AI System](#ai-system)
3. [Memory Management](#memory-management)
4. [Admin Tools](#admin-tools)
5. [Search Functionality](#search-functionality)
6. [Database Structure](#database-structure)
7. [API Integration](#api-integration)
8. [Best Practices](#best-practices)

## Architecture Overview

Nebula follows a modular architecture using Discord.py's cog system:

```
Bot Core (bot.py)
    ├── Memory Manager Cog
    ├── AI Handler Cog
    ├── Admin Tools Cog
    └── Search Tool Cog
           ↓
    Database Layer (database.py)
           ↓
    SQLite Database (nebula.db)
```

### Component Responsibilities

- **bot.py**: Main entry point, loads cogs, handles Discord connection
- **database.py**: Database abstraction layer for all data operations
- **ai_handler.py**: Processes messages, calls OpenAI API, manages tool execution
- **memory_manager.py**: Handles conversation memory and token tracking
- **admin_tools.py**: Implements moderation commands
- **search_tool.py**: Google Custom Search integration

## AI System

### Message Processing Flow

1. **Message Received** → Bot checks if it's mentioned
2. **Context Gathering** → Retrieves reply context if applicable
3. **Memory Retrieval** → Loads recent conversation history
4. **AI Processing** → Sends to OpenAI with available tools
5. **Tool Execution** → Executes any requested tool calls
6. **Response Generation** → Formats and sends response
7. **Memory Storage** → Saves conversation to database

### System Prompt

The system prompt (`system.txt`) defines Nebula's personality and capabilities. Key elements:

- **Identity**: Friendly AI admin bot
- **Behavior**: Personal, addressing users by name
- **Capabilities**: Lists available tools and features
- **Guidelines**: Rules for tool usage and interaction

### Tool System

Tools are defined in OpenAI's function calling format:

```python
{
    "type": "function",
    "function": {
        "name": "tool_name",
        "description": "What the tool does",
        "parameters": { ... }
    }
}
```

Available tools are dynamically determined based on user permissions.

### Context Window Management

- Maximum context: Limited by OpenAI model's context window
- History retrieval: Last 50 messages by default
- Token counting: Uses tiktoken for accurate GPT-4 token counts
- Automatic truncation: Older messages dropped when limit reached

## Memory Management

### Token Tracking

```python
# Token counting
def count_tokens(text: str) -> int:
    encoding = tiktoken.encoding_for_model("gpt-4")
    return len(encoding.encode(text))
```

### Memory Lifecycle

1. **Message Arrives** → Count tokens
2. **Check Limit** → Compare with 400k token limit
3. **Reset if Needed** → Clear history if limit exceeded
4. **Store Message** → Save to database with token count
5. **Update Profile** → Update user statistics

### Memory Commands

- `!memory_stats`: View current token usage
- `!reset_memory`: Clear conversation history (admin only)

### Automatic Reset

When total tokens exceed 400,000:
- Entire conversation history is cleared for the channel
- Fresh start with next message
- User profiles and admin logs are preserved

## Admin Tools

### User Moderation

#### Kick User
```
@Nebula kick @username reason here
```

**Process:**
1. Verify admin permissions
2. Parse user mention/ID
3. Check bot's role hierarchy
4. Execute kick
5. Log action to database
6. Confirm to admin

#### Ban User
```
@Nebula ban @username reason here
```

**Process:**
1. Verify admin permissions
2. Parse user mention/ID
3. Check bot's role hierarchy
4. Execute ban
5. Log action to database
6. Confirm to admin

**Note:** Bot cannot kick/ban users with roles equal to or higher than its own role.

### Channel Management

#### Create Channel
```
@Nebula create a text channel called "new-channel" in "Category Name"
```

**Supported Types:**
- Text channels
- Voice channels

**Process:**
1. Verify admin permissions
2. Find category (if specified)
3. Create channel
4. Log action
5. Return channel mention

### User Activity

#### Activity Check
```
@Nebula check activity for @username
```

**Returns:**
- User ID
- First seen date
- Last seen date
- Total message count
- Messages in last 7 days

**Data Source:** Tracked from conversation history and user profiles

### Admin Logging

All administrative actions are logged with:
- Timestamp
- Admin who performed action
- Action type
- Target user
- Reason/details

View logs with: `!admin_logs [limit]`

## Search Functionality

### Google Custom Search Integration

#### Configuration

Requires two API credentials:
1. Google Search API Key
2. Custom Search Engine ID

#### Usage

```
@Nebula search for "query here"
@Nebula can you search "latest news"
```

**Search Process:**
1. User explicitly requests search
2. AI decides to use search tool
3. Query sent to Google Custom Search API
4. Results formatted (title, snippet, URL)
5. Response sent to user

**Features:**
- Up to 10 results per search
- Rich snippets included
- Direct links provided
- Available to all users (not just admins)

#### Error Handling

- Missing API credentials → Graceful error message
- No results → "No results found" message
- API errors → Error message with details

## Database Structure

### Tables

#### conversation_history
Stores all conversation messages.

```sql
CREATE TABLE conversation_history (
    id INTEGER PRIMARY KEY,
    guild_id TEXT,
    channel_id TEXT,
    user_id TEXT,
    display_name TEXT,
    role TEXT,              -- 'user' or 'assistant'
    content TEXT,
    timestamp DATETIME,
    token_count INTEGER
)
```

#### user_profiles
Tracks user information and statistics.

```sql
CREATE TABLE user_profiles (
    user_id TEXT PRIMARY KEY,
    display_name TEXT,
    guild_id TEXT,
    first_seen DATETIME,
    last_seen DATETIME,
    message_count INTEGER
)
```

#### server_settings
Stores server-specific configuration (for future features).

```sql
CREATE TABLE server_settings (
    guild_id TEXT PRIMARY KEY,
    settings JSON,
    created_at DATETIME,
    updated_at DATETIME
)
```

#### admin_actions_log
Logs all administrative actions.

```sql
CREATE TABLE admin_actions_log (
    id INTEGER PRIMARY KEY,
    guild_id TEXT,
    admin_id TEXT,
    admin_name TEXT,
    action_type TEXT,
    target_id TEXT,
    target_name TEXT,
    details TEXT,
    timestamp DATETIME
)
```

### Database Operations

#### Adding Messages
```python
db.add_message(guild_id, channel_id, user_id, 
               display_name, role, content, token_count)
```

#### Retrieving History
```python
history = db.get_conversation_history(guild_id, channel_id, limit=50)
```

#### User Activity
```python
activity = db.get_user_activity(user_id, guild_id)
```

#### Logging Admin Actions
```python
db.log_admin_action(guild_id, admin_id, admin_name, 
                    action_type, target_id, target_name, details)
```

## API Integration

### OpenAI API

#### Configuration
```python
openai.api_key = os.getenv('OPENAI_API_KEY')
openai.base_url = os.getenv('OPENAI_BASE_URL')  # Optional
```

#### Chat Completion Call
```python
response = await openai.ChatCompletion.acreate(
    model="gpt-4-turbo-preview",
    messages=messages,
    tools=tools,
    tool_choice="auto",
    temperature=0.7,
    max_tokens=2000
)
```

#### Response Handling
- Text response: `response.choices[0].message.content`
- Tool calls: `response.choices[0].message.tool_calls`

### Google Custom Search API

#### Configuration
```python
api_key = os.getenv('GOOGLE_SEARCH_API_KEY')
search_engine_id = os.getenv('GOOGLE_SEARCH_ENGINE_ID')
```

#### API Call
```python
url = "https://www.googleapis.com/customsearch/v1"
params = {
    'key': api_key,
    'cx': search_engine_id,
    'q': query,
    'num': 5
}
```

## Best Practices

### Security

1. **Never commit API keys** to version control
2. **Use .env files** for sensitive configuration
3. **Validate user permissions** before admin actions
4. **Check role hierarchy** before moderation
5. **Log all admin actions** for audit trails

### Performance

1. **Limit conversation history** to recent messages
2. **Monitor token usage** to prevent API overages
3. **Use async/await** for all I/O operations
4. **Batch database operations** when possible
5. **Cache frequently accessed data** (if needed)

### User Experience

1. **Always address users by name** for personalization
2. **Provide clear error messages** when things fail
3. **Split long messages** to respect Discord limits
4. **Show typing indicator** for long operations
5. **Confirm admin actions** with clear feedback

### Maintenance

1. **Regularly backup** the SQLite database
2. **Monitor API usage** and costs
3. **Check admin logs** periodically
4. **Update dependencies** for security patches
5. **Review conversation memory** token usage

### Error Handling

1. **Wrap API calls** in try-catch blocks
2. **Provide fallbacks** for missing credentials
3. **Log errors** for debugging
4. **Gracefully degrade** when features unavailable
5. **Inform users** of temporary issues

## Advanced Configuration

### Custom OpenAI Endpoint

To use OpenAI-compatible APIs (like Azure OpenAI, local models, etc.):

```env
OPENAI_BASE_URL=https://your-custom-endpoint.com/v1
```

### Adjusting Memory Limits

In `memory_manager.py`:
```python
self.max_tokens = 400000  # Adjust as needed
```

### Customizing AI Behavior

Edit `system.txt` to change:
- Personality traits
- Response style
- Tool usage guidelines
- Conversation patterns

### Adding Custom Tools

1. Define tool in `ai_handler.py`
2. Implement execution logic
3. Add to appropriate cog
4. Update documentation

## Troubleshooting Common Issues

### Bot Not Responding
- Check bot is online
- Verify Message Content Intent enabled
- Ensure bot has proper channel permissions
- Check console for error messages

### Memory Issues
- Run `!memory_stats` to check usage
- Reset if needed with `!reset_memory`
- Verify database file is writable
- Check disk space

### API Errors
- Verify API keys are correct
- Check OpenAI account has credits
- Monitor rate limits
- Check network connectivity

### Database Errors
- Ensure database file exists
- Check file permissions
- Verify SQLite is installed
- Try backing up and recreating database

## Future Enhancements

Potential features for future versions:
- Custom command prefix per server
- Role-based permissions (not just admin)
- Scheduled tasks/reminders
- Advanced search filters
- Multi-language support
- Custom tool creation interface
- Web dashboard for configuration
- Backup/restore functionality
- Enhanced analytics and reporting
- Integration with other APIs

---

For more information, see README.md or open an issue on the project repository.
