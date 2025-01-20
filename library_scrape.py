import sqlite3
from bs4 import BeautifulSoup

databasefile = "library.sqlite3"

file = open("lib.txt")
lines = file.readlines()

s = ""
for l in lines:
    s += l

def scrape(htmlstr):
  soup = BeautifulSoup(htmlstr, features="lxml")
  return soup

soup = scrape(s)
library_books = soup.find_all("div", class_='library-book')
authors = soup.find_all("div", class_='library-book-author')
titles = []
cover_img_urls = []

i = 0
# go through all the div's with class library book
for b in library_books:

    # img. Gives you src and alt
    cover = b.find('img', alt=True)
    src = cover['src']
    alt = cover['alt']
    print("title: " + alt)
    print("img url/src: " + src)
    # save them in order, ie index 1 on each list will be a book
    cover_img_urls.append(src)
    titles.append(alt)

    print(authors[i].string)
    i += 1

print("connecting to db and creating table")
with sqlite3.connect(databasefile) as conn:
    # interact here
    cursor = conn.cursor()
    print("execute('DROP TABLE IF EXISTS BOOK') to rm the existing book's table.")
    cursor.execute('DROP TABLE IF EXISTS BOOK')

    # create LIBRARY TABLE
    table_sql = """CREATE TABLE BOOK (
    Title VARCHAR(75) NOT NULL,
    Authors CHAR(125) NOT NULL,
    Img_URL CHAR(75)  NOT NULL);
    """

    print(f"SQL: {table_sql} executed.")
    cursor.execute(table_sql)
    print("inserting books now.")

    i = 0
    for title in titles:
        sql = f'''INSERT INTO BOOK(Title, Authors, Img_URL)
        VALUES ("{ title }", "{ authors[i].string }", "{ cover_img_urls[i] }");'''

        print(f"SQL: { sql } executed.")
        cursor.execute(sql)
        i+=1
