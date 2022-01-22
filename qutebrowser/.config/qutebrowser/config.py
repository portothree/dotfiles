import dracula.draw

config.load_autoconfig()

memex_web_path = "/home/porto/www/memex/packages/web/index.html"

c.url.default_page = memex_web_path
c.url.start_pages = [
    "https://calendar.google.com/u/0/r/week",
    "https://github.com/notifications",
    "https://news.ycombinator.com",
    memex_web_path,
]

# Colorscheme
dracula.draw.blood(c, {"spacing": {"vertical": 6, "horizontal": 8}})
