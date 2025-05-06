# Dockerize Rails (and other Ruby frameworks)

`dockerize-rails` is a framework-agnostic Ruby gem that helps you generate complete Docker development environments for Ruby applications, including:

- Rails apps (from version 4.2 to 8.0.2)
- Sinatra apps
- Future extensibility to other Ruby web frameworks

---

## 🚀 Features

- 🔍 **Auto-analyzes** your application:
  - Parses `Gemfile`, `Gemfile.lock`, and `database.yml`
  - Determines framework, language version, DB requirements, and dependencies
- 📦 **Generates**:
  - `Dockerfile`
  - `docker-compose.yml`
  - `.dockerignore`
  - Optional data volume mount instructions
- 🧠 **Supports multiple services**:
  - ✅ PostgreSQL (with version autodetection)
  - ✅ MySQL
  - ✅ Redis
  - ✅ MongoDB
- 💾 **Data restoration** support:
  - Accepts `.sql`, `.dump`, or `.bson` files for database initialization
- 🧰 **Fallback mechanisms**:
  - If the local database is unreachable, prompts user:
    - To create DB with same name as `database.yml`
    - Or specify a dump file to restore into a new DB
- 🖥️ Supports both:
  - Apple Silicon (M1/M2) Macs
  - Linux distributions (Ubuntu, CentOS)
- ❌ No external dependencies like `thor`
- ✅ Full CLI interface
- ✅ Minitest coverage

---

## 🧪 Installation (without RubyGems.org)

Clone the repo and build locally:

```bash
git clone https://github.com/your-username/dockerize-rails.git
cd dockerize-rails
gem build dockerize-rails.gemspec
gem install ./dockerize-rails-*.gem
```
