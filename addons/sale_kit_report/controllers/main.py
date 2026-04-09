import io
import xlsxwriter
from odoo import http
from odoo.http import request

class SaleKitController(http.Controller):

    @http.route('/web/export_kit_xlsx/<int:order_id>', type='http', auth='user')
    def export_kit_xlsx(self, order_id):
        order = request.env['sale.order'].browse(order_id)
        if not order.exists():
            return request.not_found()

        data = order.get_kit_breakdown_data(order_id)
        lines = data.get('lines', [])

        output = io.BytesIO()
        workbook = xlsxwriter.Workbook(output, {'in_memory': True})
        sheet = workbook.add_worksheet(f'Kit Breakdown {order.name}')

        header_style = workbook.add_format({'bold': True, 'bg_color': '#714B67', 'font_color': 'white', 'border': 1, 'align': 'center'})

        parent_text = workbook.add_format({'bold': True, 'border': 1})
        parent_num = workbook.add_format({'bold': True, 'num_format': '#,##0.00', 'border': 1})

        child_text = workbook.add_format({'border': 1, 'font_color': '#555555'})
        child_num = workbook.add_format({'num_format': '#,##0.00', 'border': 1, 'font_color': '#555555'})

        totals_label = workbook.add_format({'bold': True, 'align': 'right'})
        totals_val = workbook.add_format({'bold': True, 'num_format': '$#,##0.00', 'border': 1, 'bg_color': '#f2f2f2'})

        sheet.set_column(0, 0, 50)
        sheet.set_column(1, 6, 15)

        headers = ['Product / Component', 'Quantity', 'UoM', 'Unit Price', 'Disc. (%)', 'Taxes', 'Subtotal']
        for col, text in enumerate(headers):
            sheet.write(0, col, text, header_style)

        row_idx = 1
        for line in lines:
            is_line = line['type'] == 'line'
            t_style = parent_text if is_line else child_text
            n_style = parent_num if is_line else child_num

            indent_level = line.get('indent', 0)
            if indent_level == 0:
                product_name = line['product_name']
            else:
                spaces = "    " * indent_level
                product_name = f"{spaces}↳ {line['product_name']}"

            sheet.write(row_idx, 0, product_name, t_style)
            sheet.write(row_idx, 1, line['quantity'], n_style)
            sheet.write(row_idx, 2, line['uom'], t_style)
            sheet.write(row_idx, 3, line['unit_price'], n_style)
            sheet.write(row_idx, 4, line['discount'] if is_line else '', n_style)
            sheet.write(row_idx, 5, line['taxes'] if is_line else '', t_style)
            sheet.write(row_idx, 6, line['amount_total'], n_style)
            row_idx += 1

        row_idx += 1
        sheet.write(row_idx, 5, 'Untaxed Amount:', totals_label)
        sheet.write(row_idx, 6, data['amount_untaxed'], totals_val)
        row_idx += 1
        sheet.write(row_idx, 5, 'Taxes:', totals_label)
        sheet.write(row_idx, 6, data['amount_tax'], totals_val)
        row_idx += 1
        sheet.write(row_idx, 5, 'Total:', totals_label)
        sheet.write(row_idx, 6, data['amount_total'], totals_val)

        workbook.close()
        output.seek(0)

        file_name = f'Sale_Kit_Breakdown_{order.name}.xlsx'
        return request.make_response(
            output.getvalue(),
            headers=[
                ('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
                ('Content-Disposition', f'attachment; filename={file_name};')
            ]
        )