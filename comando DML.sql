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