import re

class RepairCsv:

    def _remove_comments(self, line):
        find_comments = r',".+",'

        # workaround to simplify regex
        line = line.replace(',"",', ",'',")

        output = re.sub(
            find_comments,
            ',"",',
            line
        )
        # executing again if multiple comments are behind each other
        output = re.sub(
            find_comments,
            ',"",',
            output
        )

        # undo workaround to simplify regex
        output = output.replace(",'',", ',"",')

        # Warning: members might still be able to crash this
        # if they excessively use quotation marks and commas...

        return output

    def _fix_dates(self, line):
        # matches this kind of format: 1.2.2024, 12:34:56
        find_date = r',(\d{1,2}\.\d{1,2}\.\d{4}), (\d{1,2}:\d{1,2}:\d{1,2}),'
        find_date_at_end = r',(\d{1,2}\.\d{1,2}\.\d{4}), (\d{1,2}:\d{1,2}:\d{1,2})$'
        date_with_quotation_marks = r',"\1, \2",'

        fixed_line = re.sub(
                find_date,
                date_with_quotation_marks,
                line
            )
        # applying it again because there are multiple dates
        # right after each other
        fixed_line = re.sub(
            find_date,
            date_with_quotation_marks,
            fixed_line
        )

        fixed_line = re.sub(
            find_date_at_end,
            date_with_quotation_marks,
            fixed_line
        )

        return fixed_line

    def repair_csv(self, source_path, target_path):
        text_lines = []
        with open(source_path, 'r', errors='replace') as f:
            text_lines = f.readlines()

        fixed_lines = []

        for line_to_fix in text_lines:

            # trying to remove comments since they are not exported properly
            # and can probably not be fixed reliably
            # Issues occur when quotation marks are used in a comment
            fixed_line = self._remove_comments(line_to_fix)

            fixed_line = self._fix_dates(fixed_line)

            fixed_lines.append(fixed_line)

        with open(target_path, 'w', encoding='utf-8') as f:
            f.writelines(fixed_lines)
