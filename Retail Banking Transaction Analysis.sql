CREATE DATABASE retail_banking;

USE retail_banking;

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(30),
    customer_since DATE,
    kyc_status VARCHAR(20),
    segment VARCHAR(30),
    annual_income DECIMAL(15,2),
    credit_score INT,
    is_active VARCHAR(3)
);


CREATE TABLE branches (
    branch_id VARCHAR(20) PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    state VARCHAR(30),
    region VARCHAR(30),
    opening_date DATE,
    employee_count INT
);



CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    branch_id VARCHAR(20) NOT NULL,
    account_type VARCHAR(50),
    open_date DATE,
    close_date DATE,
    current_balance DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    overdraft_limit DECIMAL(15,2),
    status VARCHAR(20),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
);


CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20) NOT NULL,
    branch_id VARCHAR(20) NOT NULL,
    loan_type VARCHAR(50),
    principal_amount DECIMAL(15,2),
    interest_rate DECIMAL(5,2),
    tenure_months INT,
    disbursement_date DATE,
    maturity_date DATE,
    emi_amount DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2),
    loan_status VARCHAR(30),
    purpose VARCHAR(50),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
);

CREATE TABLE loan_payments (
    payment_id VARCHAR(20) PRIMARY KEY,
    loan_id VARCHAR(20) NOT NULL,
    payment_date DATE,
    scheduled_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2),
    principal_paid DECIMAL(15,2),
    interest_paid DECIMAL(15,2),
    penalty DECIMAL(15,2),
    days_late INT,
    payment_method VARCHAR(50),
    status VARCHAR(20),

    FOREIGN KEY (loan_id)
        REFERENCES loans(loan_id)
);

CREATE TABLE cards (
    card_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    card_type VARCHAR(30),
    issue_date DATE,
    expiry_date DATE,
    credit_limit DECIMAL(15,2),
    outstanding_balance DECIMAL(15,2),
    reward_points INT,
    is_active VARCHAR(3),
    network VARCHAR(30),

    FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20) NOT NULL,
    transaction_date DATE,
    transaction_time TIME,
    transaction_type VARCHAR(50),
    amount DECIMAL(15,2),
    channel VARCHAR(50),
    description VARCHAR(100),
    balance_after DECIMAL(15,2),
    status VARCHAR(20),

    FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);


SHOW TABLES;

SET GLOBAL local_infile = 1;



SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM branches;
SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM loans;
SELECT COUNT(*) FROM loan_payments;
SELECT COUNT(*) FROM cards;
SELECT COUNT(*) FROM transactions;



-- Sprint 3: Basic Analysis / Data Exploration

# 11 What is the total number of customers?
SELECT COUNT(*) AS total_customers
FROM customers;

# 12 What is the total number of accounts?
SELECT COUNT(*) AS total_accounts
FROM accounts;

# 13 What are the different account types available?
SELECT DISTINCT account_type
FROM accounts;

# 14 How many customers are currently active?
SELECT COUNT(*) AS active_customers
FROM customers
WHERE is_active = 'Yes';

# 15 What are the different transaction types available?
SELECT DISTINCT transaction_type
FROM transactions;

# 16 What is the total amount of completed transactions?
SELECT SUM(amount) AS total_completed_transactions
FROM transactions
WHERE status = 'Completed';

# 17 What are the different loan types available?
SELECT DISTINCT loan_type
FROM loans;

# 18 What is the total number of loans?
SELECT COUNT(*) AS total_loans
FROM loans;

# 19 What are the different card types available?
SELECT DISTINCT card_type
FROM cards;

# 20 What is the total outstanding loan balance?
SELECT SUM(outstanding_balance) AS total_outstanding_balance
FROM loans;


-- 4.1 Understand Customer Profile and Segmentation

#Q1. Number of customers by segment
SELECT
    segment,
    COUNT(*) AS customer_count
FROM customers
GROUP BY segment
ORDER BY customer_count DESC;

#Q2. Average income by segment
SELECT
    segment,
    ROUND(AVG(annual_income), 2) AS average_income
FROM customers
GROUP BY segment
ORDER BY average_income DESC;

#Q3. Average credit score by segment
SELECT
    segment,
    ROUND(AVG(credit_score), 2) AS average_credit_score
FROM customers
GROUP BY segment
ORDER BY average_credit_score DESC;

#Q4. Customers by state
SELECT
    state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY state
ORDER BY customer_count DESC;

# Q5. KYC status distribution
SELECT
    kyc_status,
    COUNT(*) AS customer_count
FROM customers
GROUP BY kyc_status
ORDER BY customer_count DESC;

# Q6. Active vs inactive customers
SELECT
    is_active,
    COUNT(*) AS customer_count
FROM customers
GROUP BY is_active;

# Sprint 4.2 — Account Usage & Branch Activity

# Q7. Accounts by account type
SELECT
    account_type,
    COUNT(*) AS account_count
FROM accounts
GROUP BY account_type
ORDER BY account_count DESC;

# Q8. Average balance by account type
SELECT
    account_type,
    ROUND(AVG(current_balance), 2) AS average_balance
FROM accounts
GROUP BY account_type
ORDER BY average_balance DESC;

# Q9. Total balance by branch
SELECT
    b.branch_id,
    b.branch_name,
    ROUND(SUM(a.current_balance), 2) AS total_balance
FROM branches b
JOIN accounts a
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_balance DESC;

# Q10. Account activity by branch
SELECT
    b.branch_name,
    COUNT(a.account_id) AS total_accounts
FROM branches b
LEFT JOIN accounts a
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_accounts DESC;

# Q11. Average interest rate by account type
SELECT
    account_type,
    ROUND(AVG(interest_rate), 2) AS average_interest_rate
FROM accounts
GROUP BY account_type
ORDER BY average_interest_rate DESC;

# Q12. Active vs closed accounts
SELECT
    status,
    COUNT(*) AS account_count
FROM accounts
GROUP BY status;

# Sprint 4.3 — Transaction Patterns
# Q13. Most common transaction types
SELECT
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;

# Q14. Transactions by channel
SELECT
    channel,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY channel
ORDER BY transaction_count DESC;

# Q15. Transaction amount by type
SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions
GROUP BY transaction_type
ORDER BY total_amount DESC;

# Q16. Transactions by channel and type
SELECT
    channel,
    transaction_type,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY channel, transaction_type
ORDER BY transaction_count DESC;

# Q17. Transaction activity by month
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS month,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions
GROUP BY DATE_FORMAT(transaction_date, '%Y-%m')
ORDER BY month;

# Q18. Top transaction descriptions
SELECT
    description,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY description
ORDER BY transaction_count DESC;

# Q19. Completed vs failed vs pending
SELECT
    status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY status;

# Q20. Top accounts by transaction activity
SELECT
    account_id,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_transaction_amount
FROM transactions
GROUP BY account_id
ORDER BY transaction_count DESC
LIMIT 10;

# Sprint 4.4 — Loan Performance

# Q21. Loans by loan type
SELECT
    loan_type,
    COUNT(*) AS loan_count
FROM loans
GROUP BY loan_type
ORDER BY loan_count DESC;

# Q22. Average loan amount by loan type
SELECT
    loan_type,
    ROUND(AVG(principal_amount), 2) AS average_loan_amount
FROM loans
GROUP BY loan_type
ORDER BY average_loan_amount DESC;

# Q23. Outstanding balance by loan type
SELECT
    loan_type,
    ROUND(SUM(outstanding_balance), 2) AS outstanding_balance
FROM loans
GROUP BY loan_type
ORDER BY outstanding_balance DESC;

# Q24. Loan status distribution
SELECT
    loan_status,
    COUNT(*) AS loan_count
FROM loans
GROUP BY loan_status;

# Q25. Loans by purpose
SELECT
    purpose,
    COUNT(*) AS loan_count
FROM loans
GROUP BY purpose
ORDER BY loan_count DESC;

# Q26. Loans with repayment delays
SELECT
    loan_id,
    COUNT(*) AS payment_count,
    SUM(days_late) AS total_days_late,
    MAX(days_late) AS maximum_days_late
FROM loan_payments
WHERE days_late > 0
GROUP BY loan_id
ORDER BY total_days_late DESC;

# Q27. Total penalties
SELECT
    ROUND(SUM(penalty), 2) AS total_penalties
FROM loan_payments;

# Q28. Payment status
SELECT
    status,
    COUNT(*) AS payment_count
FROM loan_payments
GROUP BY status;

# Q29. Payment methods used
SELECT
    payment_method,
    COUNT(*) AS payment_count
FROM loan_payments
GROUP BY payment_method
ORDER BY payment_count DESC;

# Q30. Loan performance by branch
SELECT
    b.branch_name,
    COUNT(l.loan_id) AS loan_count,
    ROUND(SUM(l.principal_amount), 2) AS total_principal,
    ROUND(SUM(l.outstanding_balance), 2) AS total_outstanding
FROM branches b
JOIN loans l
    ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY total_outstanding DESC;

# Sprint 4.5 — Card Usage & Product Engagement

# Q31. Cards by card type
SELECT
    card_type,
    COUNT(*) AS card_count
FROM cards
GROUP BY card_type;

# Q32. Active vs inactive cards
SELECT
    is_active,
    COUNT(*) AS card_count
FROM cards
GROUP BY is_active;

# Q33. Average credit limit by card type
SELECT
    card_type,
    ROUND(AVG(credit_limit), 2) AS average_credit_limit
FROM cards
GROUP BY card_type;

# Q34. Outstanding balance by card type
SELECT
    card_type,
    ROUND(SUM(outstanding_balance), 2) AS total_outstanding
FROM cards
GROUP BY card_type
ORDER BY total_outstanding DESC;

# Q35. Reward points by card type
SELECT
    card_type,
    SUM(reward_points) AS total_reward_points,
    ROUND(AVG(reward_points), 2) AS average_reward_points
FROM cards
GROUP BY card_type;

# Q36. Cards by network
SELECT
    network,
    COUNT(*) AS card_count
FROM cards
GROUP BY network
ORDER BY card_count DESC;

# Q37. Customers with cards
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT ca.card_id) AS card_count
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN cards ca
    ON a.account_id = ca.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY card_count DESC;

# Q38. Customers with multiple banking products
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT a.account_id) AS account_count,
    COUNT(DISTINCT ca.card_id) AS card_count,
    COUNT(DISTINCT l.loan_id) AS loan_count
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN cards ca
    ON a.account_id = ca.account_id
LEFT JOIN loans l
    ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING account_count > 0
    AND card_count > 0
    AND loan_count > 0;
    
    

