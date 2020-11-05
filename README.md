# mysqldumpdbs

Dump all MySQL databases in separate files

## Usage
### wget
```bash
bash <(wget -qO- https://github.com/ivandokov/mysqldumpdbs/blob/master/mysqldumpdbs.bash)
```

### curl
```bash
bash <(curl -sL https://github.com/ivandokov/mysqldumpdbs/blob/master/mysqldumpdbs.bash)
```
### manually
```bash
git clone https://github.com/ivandokov/mysqldumpdbs.git
cd mysqldumpdbs
bash mysqldumpdbs.bash
```

## Ignored databases

* mysql
* performance_schema
* information_schema
