\pset pager off
-- Обычный SELECT показывает только версии, видимые текущему снимку.
SELECT ctid,xmin,xmax,* FROM lab2.accounts ORDER BY id;
-- Читаем физическую страницу 0: видим в том числе старые версии.
SELECT lp,lp_flags,t_xmin,t_xmax,t_ctid
-- lp — номер элемента; t_xmin/t_xmax — транзакции создания и изменения версии.
FROM heap_page_items(get_raw_page('lab2.accounts',0)) ORDER BY lp;
