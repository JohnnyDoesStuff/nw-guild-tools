import re

class RepairCsv:

    def repair_csv(self, source_path, target_path):
        text_lines = []
        with open(source_path, 'r') as f:
            text_lines = f.readlines()

        fixed_lines = []

        # matches this kind of format: 1.2.2024, 12:34:56
        find_date = r',(\d{1,2}\.\d{1,2}\.\d{4}), (\d{1,2}:\d{1,2}:\d{1,2}),'
        find_date_at_end = r',(\d{1,2}\.\d{1,2}\.\d{4}), (\d{1,2}:\d{1,2}:\d{1,2})$'
        date_with_quotation_marks = r',"\1, \2",'

        for line_to_fix in text_lines:
            semi_fixed_line = re.sub(
                find_date,
                date_with_quotation_marks,
                line_to_fix
            )
            # applying it again because there are multiple dates
            # right after each other
            fixed_line = re.sub(
                find_date,
                date_with_quotation_marks,
                semi_fixed_line
            )

            fixed_line = re.sub(
                find_date_at_end,
                date_with_quotation_marks,
                fixed_line
            )

            fixed_lines.append(fixed_line)

        with open(target_path, 'w') as f:
            f.writelines(fixed_lines)
