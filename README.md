# Task: Deploy a Web Application with Public and Private Subnets in AWS

## Objective
Create a VPC, configure subnets (public and private), set up EC2 instances (one for a web server in the public subnet and another for a database server in the private subnet), and implement routing and security.

## Step-by-Step Instructions

### 1. Create a VPC
- Go to the VPC Dashboard in AWS Management Console.
- Click on **Create VPC**.
- Choose a CIDR block (e.g., `10.0.0.0/16` for your entire VPC).
- Leave other options at default for now.
- Click on **Create**.

### 2. Create Subnets
In the VPC dashboard, go to **Subnets** and click **Create Subnet**.

- **Public Subnet**:
    - Choose the VPC you just created.
    - Name the subnet (e.g., `Public-Subnet`).
    - CIDR Block (e.g., `10.0.1.0/24`).
    - Availability Zone: Choose any available zone.
  
- **Private Subnet**:
    - Choose the same VPC.
    - Name the subnet (e.g., `Private-Subnet`).
    - CIDR Block (e.g., `10.0.2.0/24`).
    - Availability Zone: Choose a different one for better high availability.

- Click **Create Subnet** after both subnets are configured.

### 3. Set Up an Internet Gateway
- Go to **Internet Gateways** in the VPC Dashboard.
- Click **Create Internet Gateway** and give it a name (e.g., `My-Internet-Gateway`).
- Click **Attach to VPC** and select your VPC.

### 4. Configure Route Tables

#### Public Subnet Route Table:
- Go to **Route Tables** and create a new one.
- Name it (e.g., `Public-Route-Table`).
- Under **Routes**, click **Edit Routes** and add a route to the internet:
    - **Destination**: `0.0.0.0/0`
    - **Target**: Choose the Internet Gateway you created earlier.
- Associate this route table with your Public Subnet.

#### Private Subnet Route Table:
- For now, leave the default route table for the private subnet (no direct route to the internet).

### 5. Set Up EC2 Instances

#### Public EC2 (Web Server):
- Launch an EC2 instance in the Public Subnet.
- Use an Amazon Linux 2 AMI.
- Select an Instance Type (e.g., `t2.micro`).
- Assign a Public IP to the instance.
- Configure the Security Group to allow HTTP (port 80) and SSH (port 22) for administrative access.

#### Private EC2 (Database Server):
- Launch an EC2 instance in the Private Subnet.
- Use the same AMI (Amazon Linux 2).
- Select an Instance Type (e.g., `t2.micro`).
- Do not assign a Public IP (it should only be accessible from within the VPC).
- Configure the Security Group to allow only SSH (port 22) from the Public EC2's private IP and MySQL traffic (port 3306) from the web server.

### 6. Create a Security Group for Communication

#### Public EC2 Security Group:
- **Inbound**: SSH (22), HTTP (80)
- **Outbound**: All traffic.

#### Private EC2 Security Group:
- **Inbound**: MySQL (3306) from Public EC2's private IP.
- **Outbound**: All traffic.

### 7. Connect Web Server to Database Server

#### Step 1: Set Up the Web Server on Public EC2
- **Connect to Public EC2 Instance**:
    - Open your terminal or AWS CloudShell.
    - Use the public IP of your EC2 instance and connect via SSH:
      ```bash
      ssh -i "your-key.pem" ec2-user@<public-ec2-public-ip>
      ```

- **Install Apache Web Server**:
    - Update the system and install Apache:
      ```bash
      sudo yum update -y
      sudo yum install httpd -y
      ```
    - Start and enable Apache to run on boot:
      ```bash
      sudo systemctl start httpd
      sudo systemctl enable httpd
      ```

- **Set Up a Basic HTML Page**:
    - Create a simple HTML file in the web server directory:
      ```bash
      echo "<h1>Welcome to My Web Server</h1>" | sudo tee /var/www/html/index.html
      ```
    - Verify that the web server is working:
      Open your browser and navigate to the public IP of the EC2 instance (`http://<public-ec2-public-ip>`). You should see the message: "Welcome to My Web Server".

#### Step 2: Set Up the Database Server on Private EC2
- **Connect to Private EC2 Instance**:
    - SSH into the Public EC2 instance:
      ```bash
      ssh -i "your-key.pem" ec2-user@<public-ec2-public-ip>
      ```

    - From the Public EC2, SSH into the Private EC2 using its private IP:
      ```bash
      ssh -i "your-key.pem" ec2-user@<private-ec2-private-ip>
      ```

- **Install MySQL Database**:
    - Update the system and install MySQL:
      ```bash
      sudo yum update -y
      sudo yum install mysql-server -y
      ```
    - Start and enable MySQL:
      ```bash
      sudo systemctl start mysqld
      sudo systemctl enable mysqld
      ```

- **Configure the Database**:
    - Login to MySQL:
      ```bash
      sudo mysql
      ```
    - Create a database and a user for the web server:
      ```sql
      CREATE DATABASE webapp;
      CREATE USER 'webuser'@'%' IDENTIFIED BY 'password';
      GRANT ALL PRIVILEGES ON webapp.* TO 'webuser'@'%';
      FLUSH PRIVILEGES;
      EXIT;
      ```

- **Allow Connections to MySQL**:
    - Modify the MySQL configuration to listen on all IPs:
      ```bash
      sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/my.cnf
      sudo systemctl restart mysqld
      ```

    - Ensure the Security Group for the Private EC2 allows inbound traffic on port 3306 from the Private IP of the Public EC2.

#### Step 3: Test Connectivity from Web Server to Database

- **Install MySQL Client on the Public EC2**:
    - Connect to the Public EC2 via SSH and install the MySQL client:
      ```bash
      sudo yum install mysql -y
      ```

- **Test the Connection**:
    - From the Public EC2, connect to the MySQL server running on the Private EC2:
      ```bash
      mysql -h <private-ec2-private-ip> -u webuser -p
      ```

    - Enter the password you set (`password`).
    - If successful, you’ll see the MySQL prompt. Test the database:
      ```sql
      SHOW DATABASES;
      ```

### 8. Test the Setup

#### Verify Web Server Access:
- Open a browser and visit the public IP of the Public EC2 (`http://<public-ec2-public-ip>`). You should see the HTML page served by Apache.
- Try connecting to the Private EC2 from the Public EC2 using the database client and verify that the web server can query the database.

#### Verify Database Access:
- Ensure that the web server can query the database by running a script or query as shown above.

### 9. Optional - Set Up a NAT Gateway for Private Subnet

#### Create a NAT Gateway:
- Go to the VPC Dashboard → **NAT Gateways** → **Create NAT Gateway**.
- Assign it to the Public Subnet.
- Allocate an Elastic IP (this provides the NAT Gateway with internet access).
- Click **Create NAT Gateway**.

#### Update Private Subnet Route Table:
- Go to **Route Tables** and find the one associated with your Private Subnet.
- Edit the routes to add the following:
  - **Destination**: `0.0.0.0/0`
  - **Target**: Select the NAT Gateway.

#### Test Internet Access from Private EC2:
- SSH into the Private EC2 (via the Public EC2).
- Test internet connectivity by pinging an external site:
  ```bash
  ping google.com
  
#### What You’ve Learned:
- How to set up a VPC and organize subnets.
- How to configure routing and security for private and public subnets.
- How to launch EC2 instances and manage their security groups.
- How to connect resources securely across subnets.
