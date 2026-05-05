# 데이터베이스 문자 집합 변경 
ALTER DATABASE ranking_model
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

# 
SHOW DATABASES;
USE ranking_model;
SELECT 
(select count(*) from sales) as sales_cnt,
(select count(*) from trade_area) as trade_cnt,
(select count(*) from stores) as stores_cnt;

describe sales;
describe trade_area;
describe stores;

# 공통 컬럼 찾기
select column_name
from information_schema.columns
where table_schema = 'ranking_model' 
	and table_name in ('sales','trade_area','stores')
group by column_name
having count(distinct table_name) = 3;

desc trade_area;

# sales columns
select 
	concat(' s.`',column_name,'`,') as sales_columns
from information_schema.columns
where table_schema = 'ranking_model'
	and table_name = 'sales'
order by ordinal_position

# stores columns
select 
	concat(' st.`',column_name, '`,') as stores_columns
from information_schema.columns
where table_schema = 'ranking_model'
	and table_name = 'stores'
	and column_name not in ('기준_년분기_코드', '상권_코드', '상권_구분_코드')
order by ordinal_position

# trade_area columns
select 
	concat(' t.`',column_name, '`,') as trade_area_columns
from information_schema.columns
where table_schema = 'ranking_model'
	and table_name = 'trade_area'
	and column_name not in ('기준_년분기_코드', '상권_코드', '상권_구분_코드')
order by ordinal_position

# sales 컬럼 구조 변
ALTER TABLE sales 
MODIFY `상권_구분_코드` VARCHAR(20),
MODIFY `상권_구분_코드_명` VARCHAR(20),
MODIFY `상권_코드_명` VARCHAR(30),
MODIFY `서비스_업종_코드` VARCHAR(20),
MODIFY `서비스_업종_코드_명` VARCHAR(20);

ALTER TABLE stores 
MODIFY `상권_구분_코드` VARCHAR(20),
MODIFY `상권_구분_코드_명` VARCHAR(20),
MODIFY `상권_코드_명` VARCHAR(30),
MODIFY `서비스_업종_코드` VARCHAR(20),
MODIFY `서비스_업종_코드_명` VARCHAR(20);

ALTER TABLE trade_area 
MODIFY `상권_구분_코드` VARCHAR(20),
MODIFY `상권_구분_코드_명` VARCHAR(20),
MODIFY `상권_코드_명` VARCHAR(40),
MODIFY `상권_변화_지표` VARCHAR(20),
MODIFY `상권_변화_지표_명` VARCHAR(20);

# 인덱스 삭제
DROP INDEX idx_sales_join ON sales;
DROP INDEX idx_stores_join ON stores;
DROP INDEX idx_trade_area_join ON trade_area;

# 조인전 인덱스 생성
CREATE INDEX idx_sales_join ON sales (`기준_년분기_코드`, `상권_코드`, `상권_구분_코드`, `서비스_업종_코드`);
CREATE INDEX idx_stores_join ON stores (`기준_년분기_코드`, `상권_코드`, `상권_구분_코드`, `서비스_업종_코드`);
CREATE INDEX idx_trade_area_join ON trade_area (`기준_년분기_코드`, `상권_코드`, `상권_구분_코드`);

# drop commercial_distinct table 
DROP TABLE IF EXISTS commercial_distinct;

# create table
CREATE TABLE commercial_distinct AS
SELECT 
	s.`기준_년분기_코드`,
    s.`상권_구분_코드`,
    s.`상권_구분_코드_명` AS 상권_구분_코드_명,
    s.`상권_코드`,
    s.`상권_코드_명` AS sales_상권_코드_명,
    s.`서비스_업종_코드`,
    s.`서비스_업종_코드_명` AS sales_서비스_업종_코드_명,
    s.`당월_매출_금액`,
    s.`당월_매출_건수`,
    s.`주중_매출_금액`,
    s.`주말_매출_금액`,
    s.`월요일_매출_금액`,
    s.`화요일_매출_금액`,
    s.`수요일_매출_금액`,
    s.`목요일_매출_금액`,
    s.`금요일_매출_금액`,
    s.`토요일_매출_금액`,
    s.`일요일_매출_금액`,
    s.`시간대_00~06_매출_금액`,
    s.`시간대_06~11_매출_금액`,
    s.`시간대_11~14_매출_금액`,
    s.`시간대_14~17_매출_금액`,
    s.`시간대_17~21_매출_금액`,
    s.`시간대_21~24_매출_금액`,
    s.`남성_매출_금액`,
    s.`여성_매출_금액`,
    s.`연령대_10_매출_금액`,
    s.`연령대_20_매출_금액`,
    s.`연령대_30_매출_금액`,
    s.`연령대_40_매출_금액`,
    s.`연령대_50_매출_금액`,
    s.`연령대_60_이상_매출_금액`,
    s.`주중_매출_건수`,
    s.`주말_매출_건수`,
    s.`월요일_매출_건수`,
    s.`화요일_매출_건수`,
    s.`수요일_매출_건수`,
    s.`목요일_매출_건수`,
    s.`금요일_매출_건수`,
    s.`토요일_매출_건수`,
    s.`일요일_매출_건수`,
    s.`시간대_건수~06_매출_건수`,
    s.`시간대_건수~11_매출_건수`,
    s.`시간대_건수~14_매출_건수`,
    s.`시간대_건수~17_매출_건수`,
    s.`시간대_건수~21_매출_건수`,
    s.`시간대_건수~24_매출_건수`,
    s.`남성_매출_건수`,
    s.`여성_매출_건수`,
    s.`연령대_10_매출_건수`,
    s.`연령대_20_매출_건수`,
    s.`연령대_30_매출_건수`,
    s.`연령대_40_매출_건수`,
    s.`연령대_50_매출_건수`,
    s.`연령대_60_이상_매출_건수`,
    st.`점포_수`,
    st.`유사_업종_점포_수`,
    st.`개업_율`,
    st.`개업_점포_수`,
    st.`폐업_률`,
    st.`폐업_점포_수`,
    st.`프랜차이즈_점포_수`,
    t.`상권_변화_지표`,
    t.`상권_변화_지표_명`,
    t.`운영_영업_개월_평균`,
    t.`폐업_영업_개월_평균`,
    t.`서울_운영_영업_개월_평균`,
    t.`서울_폐업_영업_개월_평균`
from sales s
LEFT JOIN stores st
	ON s.`기준_년분기_코드` = st.`기준_년분기_코드` 
    AND s.`상권_코드` = st.`상권_코드`
    AND s.`상권_구분_코드` = st.`상권_구분_코드`
    AND s.`서비스_업종_코드` = st.`서비스_업종_코드`
LEFT JOIN trade_area t
    ON s.`기준_년분기_코드` = t.`기준_년분기_코드`
    AND s.`상권_코드` = t.`상권_코드`
    AND s.`상권_구분_코드` = t.`상권_구분_코드`;

desc commercial_distinct;

-- 2. 컬럼 정보 확인
show columns from sales like '기준_년분기_코드';
show columns from sales like '상권_코드';

이렇게 했으면 이제 파이썬에서 작성하면 되는거지?