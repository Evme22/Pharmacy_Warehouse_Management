from flask import Flask, render_template, request, redirect, session, url_for
from db import get_connection
import os
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv('FLASK_SECRET_KEY')

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']

        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT id, role FROM users WHERE username=%s AND password=%s", (username, password))
        user = cursor.fetchone()
        cursor.close()
        conn.close()

        if user:
            session['user_id'] = user[0]
            session['username'] = username
            session['role'] = user[1]
            return redirect('/')
        else:
            error = 'Неверный логин или пароль'

    return render_template('login.html', error=error)

@app.route('/logout')
def logout():
    session.clear()
    return redirect('/login')


@app.route('/')
def index():
    if 'username' not in session:
        return redirect('/login')

    return render_template('index.html', role=session['role'])


@app.route('/procedures', methods=['GET', 'POST'])
def procedures():
    result = None
    columns = []
    error = None
    is_error_result = False

    if request.method == 'POST':
        proc = request.form.get('procedure')

        try:
            conn = get_connection()
            cursor = conn.cursor()

            if proc == 'Get_Medicines_By_Group':
                group_id = request.form.get('group_id')
                if not group_id or not group_id.isdigit():
                    raise ValueError("Введите корректный числовой ID группы.")
                group_id = int(group_id)
                cursor.callproc('Get_Medicines_By_Group', [group_id])

            elif proc == 'Get_Medicines_By_Price_Range':
                min_price = request.form.get('min_price')
                max_price = request.form.get('max_price')
                if not min_price or not max_price:
                    raise ValueError("Введите обе границы цен.")
                min_price = float(min_price)
                max_price = float(max_price)
                cursor.callproc('Get_Medicines_By_Price_Range', [min_price, max_price])

            elif proc == 'Get_Medicines_By_Manufacturer':
                manufacturer_id = request.form.get('manufacturer_id')
                if not manufacturer_id or not manufacturer_id.isdigit():
                    raise ValueError("Введите корректный ID производителя.")
                manufacturer_id = int(manufacturer_id)
                cursor.callproc('Get_Medicines_By_Manufacturer', [manufacturer_id])

            elif proc == 'Get_Supplied_Medicines_By_Pharmacy':
                pharmacy_id = request.form.get('pharmacy_id')
                if not pharmacy_id or not pharmacy_id.isdigit():
                    raise ValueError("Введите корректный ID аптеки.")
                pharmacy_id = int(pharmacy_id)
                cursor.callproc('Get_Supplied_Medicines_By_Pharmacy', [pharmacy_id])

            elif proc == 'Get_Supplied_Medicines_By_Supplier':
                supplier_id = request.form.get('supplier_id')
                if not supplier_id or not supplier_id.isdigit():
                    raise ValueError("Введите корректный ID поставщика.")
                supplier_id = int(supplier_id)
                cursor.callproc('Get_Supplied_Medicines_By_Supplier', [supplier_id])

            elif proc == 'Get_Medicine_Movement_By_Period':
                start_date = request.form.get('start_date')
                end_date = request.form.get('end_date')
                if not start_date or not end_date:
                    raise ValueError("Введите обе даты.")
                cursor.callproc('Get_Medicine_Movement_By_Period', [start_date, end_date])

            elif proc == 'Get_Avg_Selling_Top10':
                cursor.callproc('Get_Avg_Selling_Top10')

            elif proc == 'Get_Top_Suppliers_By_Period':
                start_date = request.form.get('start_date')
                end_date = request.form.get('end_date')
                if not start_date or not end_date:
                    raise ValueError("Введите обе даты.")
                cursor.callproc('Get_Top_Suppliers_By_Period', [start_date, end_date])

            elif proc == 'Get_Most_Demanded_Medicines':
                cursor.callproc('Get_Most_Demanded_Medicines')

            elif proc == 'Get_Low_Supply_Medicines_By_Period':
                start_date = request.form.get('start_date')
                end_date = request.form.get('end_date')
                if not start_date or not end_date:
                    raise ValueError("Введите обе даты.")
                cursor.callproc('Get_Low_Supply_Medicines_By_Period', [start_date, end_date])


            else:
                raise ValueError("Неизвестная процедура.")

            for result_set in cursor.stored_results():
                result = result_set.fetchall()
                columns = result_set.column_names
                if 'error_message' in columns:
                    is_error_result = True

            cursor.close()
            conn.close()

        except Exception as e:
            error = f"Ошибка: {str(e)}"

    return render_template(
        'procedures.html',
        result=result,
        columns=columns,
        error=error,
        is_error_result=is_error_result
    )

@app.route('/analytics')
def analytics():
    try:
        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            SELECT supply_date, SUM(quantity) 
            FROM Supply_to_warehouse stw
            JOIN Supply_warehouse_items swi ON stw.supply_id = swi.supply_id
            GROUP BY supply_date ORDER BY supply_date;
        """)
        data1 = cursor.fetchall()
        dates = [str(row[0]) for row in data1]
        amounts = [int(row[1]) for row in data1]

        cursor.callproc('Get_Avg_Selling_Top10')
        for result in cursor.stored_results():
            top10 = result.fetchall()
        top_labels = [row[0] for row in top10]
        top_values = [int(row[2]) for row in top10]

        cursor.execute("""
            SELECT mg.group_name, SUM(swi.quantity)
            FROM Medicine m
            JOIN Medicine_group mg ON m.group_id = mg.group_id
            JOIN Supply_warehouse_items swi ON m.medicine_id = swi.medicine_id
            GROUP BY mg.group_name;
        """)
        pie_data = cursor.fetchall()
        pie_labels = [row[0] for row in pie_data]
        pie_values = [int(row[1]) for row in pie_data]

        cursor.close()
        conn.close()

        return render_template("analytics.html",
                               dates=dates, amounts=amounts,
                               top_labels=top_labels, top_values=top_values,
                               pie_labels=pie_labels, pie_values=pie_values)

    except Exception as e:
        return f"Ошибка при построении графиков: {str(e)}"


@app.route('/table/<table_name>')
def show_table(table_name):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name}")
    rows = cursor.fetchall()
    columns = [col[0] for col in cursor.description]
    cursor.close()
    conn.close()
    return render_template('table_view.html', table=table_name, columns=columns, rows=rows)

if __name__ == '__main__':
    app.run(debug=True)
