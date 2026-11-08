# CS169 hw-rspec-rails-intro（CHIP 8.5 RSpec/TDD + TMDb 检索）

## 已通过的公开验证（2026-11-08）

验收分支 `edidada/cs169-hw`，HEAD `0da7d69bc2d534f9ff1e132fc499e5e472010479`，[Actions run](https://github.com/edidada/cs169-hw-rspec-rails-intro/actions) branch-push 成功，8/8 rspec 断言通过：

- 官方说明书 walkthrough controller spec（searches TMDb / render_template / assigns）3 例
- 说明书 model spec（Faraday with cs169.org）1 例
- 自行 TDD 产出：missing-field warning、no-matches warning redirect、add_movie 创建+flash+redirect 3 例；WebMock-stubbed `find_in_tmdb` 返回两条 unsaved Movie（rating=R）1 例

## 实现

- `config/routes.rb`：`GET /search`→`movies#search_tmdb`、`POST /add_movie`→`movies#add_movie`
- `app/models/movie.rb`：`find_in_tmdb(String|Hash)` — 字符串直接 `Faraday.get`（说明书.walkthrough case），hash 拼接 `api.themoviedb.org/3/search/movie` 查询（`TmdbConfig::API_KEY`/`SEARCH_URI` 来自 initializer，GitHub 上不存真实 key），解析 JSON 为 unsaved `Movie.new` 列表（搜索接口无 MPAA 分级，rating 全 R）
- `app/controllers/movies_controller.rb`：`search_tmdb` 支持 walkthrough 的 `search_terms` 参数与正式表单 `title/release_year/language`；missing-input→flash warning redirect，无匹配→flash warning redirect，否则 `@movies` 落地渲染结果模板；`add_movie` 建 movie 后 redirect 回 search 并带 notice
- `app/views/movies/search_tmdb.html.erb`：表单 id `tmdb_form`、Language 单选、Return-to-list button，结果表 id `search_movies`，每行 Add Movie 提交 hidden 字段表（title/rating/description/release_date）
- 说明书改用 `rails-controller-testing` gem 于 dev/test 组（assigns/render_template helpers）
- 测试：官方 walkthrough spec（原文给定）+ 自写 TDD 断言（matching 说明书 red-green 流程），`spec/spec_helper.rb` 接 WebMock 禁止真实外网（api.themoviedb.org stub 为 canned "Olympics" 响应）

## 边界与局限

- 全部构建/spec 运行都在 GitHub Actions；本地不编译运行。
- 不做 Render/Heroku 云部署 E2E（说明书里的 deploy 部分要求外部平台托管，属环境型，已经记录为待），也不把 TMDb 真实 API key 写进公开仓库。
- Gemini 之类例子外的断言逻辑由自写 spec 驱动行为：根据 hw 说明书中的书面/示例内容自实现，未超出官方 spec 边界。
