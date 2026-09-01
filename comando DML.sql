-- listar produtos acima de 1000.
select * 
from products
where price > 1000;

-- Ordenar produto pelo preço do maior para o menor
select *
from products
order by price DESC;

-- Aumentar preços da dell em 10%
update products
set price = price *1.10
where name ilike '%Dell%';

-- Deletar todod Macbooks
delete 
from products
where name ilike '%Macbook%'

-- excluir produto que não possui pedido associado
delete from products 
where id not in (
    select distinct product_id 
    from orders_products
);

-- Listar pedidos dos ultimos 30 dias
select * 
from orders 
where order_date >= now() - interval '30 days';

-- listar os pedidos e os nomes dos usuários
select 
    orders.id as pedido_id, 
    orders.order_date, 
    orders.status, 
    orders.total, 
    users.name as usuario_nome
from orders 
join users on orders.user_id = users.id;

-- Listar todos os usuário e seus pedidos e os que não possum pedidos.
select 
    users.id as usuario_id, 
    users.name as usuario_nome, 
    orders.id as pedido_id, 
    orders.status, 
    orders.total
from users
left join orders on users.id = orders.user_id;

-- Listar todos que realizam apenas 1 pedido
select DISTINCT 
    users.id, 
    users.name, 
    users.email
from users
join orders ON users.id = orders.user_id;

-- Listar produtos que nunca foram vendidos
select 
    products.id, 
    products.name, 
    products.price
from products
left join orders_products ON products.id = orders_products.product_id
where orders_products.product_id IS NULL;

--Listar usuários que nunca pediram
select 
    users.id, 
    users.name, 
    users.email
from users
left JOIN orders ON users.id = orders.user_id
where orders.id IS NULL;

-- Listar produtos com preço > da média
select 
    id, 
    name, 
    price
from products
where price > (select AVG(price) FROM products)
ORDER BY price DESC;

-- listar a quantidade de pedidos feito por cada usuário
select 
    users.id, 
    users.name, 
    COUNT(orders.id) as total_pedidos
from users
left join orders ON users.id = orders.user_id
GROUP BY users.id, users.name
order by total_pedidos DESC;

-- Os 3 primeiros mais vendidos
select 
    products.id, 
    products.name, 
    SUM(orders_products.quantity) as quantidade_total_vendida
from products
join orders_products on products.id = orders_products.product_id
GROUP BY products.id, products.name
ORDER BY quantidade_total_vendida DESC
limit 3;

-- gerar relatorio
select 
    users.id, 
    users.name, 
    COUNT(orders.id) as quantidade_pedidos,
    COALESCE(SUM(orders.total), 0.00) as valor_total_comprado
from users
left join orders on users.id = orders.user_id
GROUP BY users.id, users.name
ORDER BY valor_total_comprado DESC;







--1 Resumo dos pedidos por usuários (id)


-- Relatorios de vendas de produtos(id, produto, qtd_vedida, total_vendido)
drop view exists v_products_sales;
create view v_products_sales as
select
    p.id id,
    p.name produto,
    sum(op.quantity) qtd_vendida,
    sum(op.quantity * op.unit_price) total_vendido
from products
join orders_products op on op.products_id = p.id
join orders o on o.id = op.order_id
where o.status <> 'canceled'
group by p.id, p.name; 

-- 3 Relatório detalhado
drop view if exists v_orders_details as
select
    o.id id,
    u.name usuario,
    u.email email,
    o.order_date,
    o.satus,
    p.name produto,
    op.quantity qtd,
    op.unit_price valor_unitario,
    op.unit_price * op.quantity valor_total
from orders 
join user u on u.id = o.user_id
join orders_products op on op.order_id = o.id
join products p on p.id = op.product_id;

-- select * from  v_order_details order by id;

-- 4 relatório de itens em estoque
drop view if exists v_products_in_stock;
create view v_products_in_stock as
select
    id,
    name produto,
    price valor,
    stock estoque
from products
where stock > 0;

-- select * from v_products_in_stock;

update v_products_in_stock
set estoque = 0
where id = 1
returning id, produto, estoque;