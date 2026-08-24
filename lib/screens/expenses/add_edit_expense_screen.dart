import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense; // null = add mode, non-null = edit mode

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}
//this will create the state of the widget
class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = AppConstants.categories.first; //this will be the initial value for the category dropdown menu
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditMode => widget.expense != null; //this will check if the expense is null or not

  @override
  void initState() { //this will initialize the state of the widget when it is created 
    super.initState();
    if (_isEditMode) {
      final e = widget.expense!;
      _nameController.text = e.name;
      _amountController.text = e.amount.toString();
      _descController.text = e.description;
      _selectedCategory = e.category;
      _selectedDate = e.date;
    }
  }

  @override
  void dispose() { //this will dispose of the controllers when the widget is disposed 
    _nameController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }
//this will pick the date from the date picker
  Future<void> _pickDate() async { //this will open the date picker when the user taps on the date field
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppTheme.lightGreen,
              surface: AppTheme.cardDark,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
//this will submit the expense data to the provider 
//this will validate the form and update the expense data to the provider if the expense is not null 
//this will set the loading state to true and then false 

  Future<void> _submit() async { //this will submit the expense data to the provider 
    if (!_formKey.currentState!.validate()) { //this will validate the form 
      return;
    }

    setState(() => _isLoading = true); //this will set the loading state to true

    final provider = context.read<ExpenseProvider>(); //this will get the expense provider
    final now = DateTime.now(); //this will get the current date and time
//this will update the expense data to the provider if the expense is not null
    bool success;
    if (_isEditMode) { //this will check if the expense is not null and update the expense data to the provider if the expense is not null
      final updated = widget.expense!.copyWith(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()), //this will convert the amount to a double
        category: _selectedCategory,
        description: _descController.text.trim(),
        date: _selectedDate,
      );
      success = await provider.editExpense(updated); //this will update the expense data to the provider 
    } else {
      final expense = Expense( //this will create the expense object for a new expense 
        id: '',
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()), //this will convert the amount to a double
        category: _selectedCategory,
        description: _descController.text.trim(),
        date: _selectedDate,
        createdAt: now,
      );
      success = await provider.addExpense(expense); //this will add the expense data to the provider 
    }

    setState(() => _isLoading = false); //this will set the loading state to false 

    if (success && mounted) { //this will check if the expense data is added successfully and if the widget is mounted 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Expense updated successfully!'
                : 'Expense added successfully!',
          ),
        ),
      );
      Navigator.pop(context); //this will pop the widget from the navigator and return to the previous screen 
    }
  }
//this will build the widget 
  @override
  Widget build(BuildContext context) { //this will build the widget 
    context.watch<ThemeProvider>(); //this will watch the theme provider for changes 
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Expense' : 'Add Expense',
          style: GoogleFonts.poppins(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppTheme.cardDark,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expense Name
              _SectionLabel('Expense Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g., Lunch, Bus ticket...',
                  prefixIcon: Icon(
                    Icons.label_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),

              const SizedBox(height: 20),

              // Amount
              _SectionLabel('Amount (\$)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.attach_money_rounded,
                    color: AppTheme.textHint,
                    size: 20,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(val.trim());
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Date
              _SectionLabel('Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: AppTheme.textHint,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDate),
                        style: GoogleFonts.poppins(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppTheme.textHint,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Category
              _SectionLabel('Category'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: AppConstants.categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color =
                      AppConstants.categoryColors[cat] ?? AppTheme.lightGreen;
                  final icon =
                      AppConstants.categoryIcons[cat] ?? Icons.category;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.2)
                            : AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : AppTheme.dividerColor,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? color : AppTheme.textHint,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? color
                                  : AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Description
              _SectionLabel('Description (Optional)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.poppins(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a note...',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.notes_rounded,
                      color: AppTheme.textHint,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Update Expense' : 'Add Expense',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
