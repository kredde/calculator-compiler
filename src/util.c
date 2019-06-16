#include "util.h"
#include <math.h>

struct node *symbol_table_start = NULL;

char *get_id(struct node *n) { return n->id; }

float get_float(struct node *n) { return n->f; }

int get_int(struct node *n) { return n->i; }

struct node *get_next(struct node *n) {
  return n->next;
}

int get_data_type(struct node *n) { return n->data_type; }

int get_qualifier_type(struct node *n) { return n->qualifier_type; }

void set_id(struct node *n, char *id) {
  if (id) {
    n->id = malloc(sizeof(char) * (strlen(id) + 1));
    strcpy(n->id, id);
  } else {
    n->id = NULL;
  }
}

void set_float(struct node *n, float f) { n->f = f; }

void set_int(struct node *n, int i) { n->i = i; }

void set_next(struct node *n, struct node *next) { n->next = next; }

void set_data_type(struct node *n, int data_type) { n->data_type = data_type; }

void set_qualifier_type(struct node *n, int qualifier_type) {
  n->qualifier_type = qualifier_type;
}

struct node *create_entry(char *id, int qualifier_type, int data_type) {
  struct node *ptr;
  ptr = malloc(sizeof(struct node));
  if (ptr) {
    set_id(ptr, id);
    set_float(ptr, 0);
    set_int(ptr, 0);
    set_qualifier_type(ptr, qualifier_type);
    set_data_type(ptr, data_type);
  } else {
    printf("[ERROR] => no memory allocated.\n");
  }
  return ptr;
}

struct node *insert(struct node *n) {
  if (n) {
    set_next(n, symbol_table_start);
    symbol_table_start = n;
  }
  return n;
}

struct node *lookup(char *to_search) {
  struct node *ptr;
  for (ptr = symbol_table_start; ptr != NULL; ptr = get_next(ptr)) {
    char *currname = get_id(ptr);
    int different = strcmp(currname, to_search);
    if (!different) {
      return ptr;
    }
  }
  return NULL;
}

float eval_func(struct node *n, float value) {
  if (!strcmp(get_id(n), "sqrt")) {
    if (value < 0) {
      printf("[ERROR] => sqrt: argument must be greater than or equal to 0, "
             "returned 1.\n");
      return 1;
    } else {
      return sqrt(value);
    }
  } else if (!strcmp(get_id(n), "sin")) {
    return sinf(value);
  } else if (!strcmp(get_id(n), "cos")) {
    return cosf(value);
  } else if (!strcmp(get_id(n), "tan")) {
    return tanf(value);
  } else if (!strcmp(get_id(n), "log2")) {
    if (value <= 0) {
      printf("[ERROR] => log2: argument must be greater than 0, returned 1.\n");
      return 1;
    } else {
      return log2(value);
    }
  } else if (!strcmp(get_id(n), "log10")) {
    if (value <= 0) {
      printf(
          "[ERROR] => log10: argument must be greater than 0, returned 1.\n");
      return 1;
    } else {
      return log10(value);
    }
  } else if (!strcmp(get_id(n), "ln")) {
    if (value <= 0) {
      printf("[ERROR] => ln: argument must be greater than 0, returned 1.\n");
      return 1;
    } else {
      return log(value);
    }
  } else if (!strcmp(get_id(n), "fac")) {
    if (is_integer(value)) {
      return fac((int)value);
    } else {
      printf("[ERROR] => fac: argument must be an integer, returned 1.\n");
      return 1;
    }

  } else {
    printf("[ERROR => function not found.]\n");
  }
  return 0;
}

int is_integer(float f) {
  int truncated = (int)f;
  return truncated == f;
}

int fac(int i) {
  if (i > 12) {
    printf("[ERROR] => factorial is out of range (max 12), returned %i.\n", i);
    return i;
  } else if (i <= 0) {
    if (i < 0) {
      printf("[ERROR] => factorial of a negative integer is not defined, "
             "returned 1.\n");
    }
    return 1;
  } else {
    return i * fac(i - 1);
  }
}