#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// constants for qualifier_type
#define UNDEF 0
#define VAR 1
#define CONST 2
#define FUNC 3

struct node {
  char *id;
  float f;
  int i;
  int data_type;      // BOOL, NUMBER or UNDEF
  int qualifier_type; // VAR, CONST, FUNC or UNDEF
  struct node *next;
};

float eval_func(struct node *, float);
int fac(int);

struct node *create_entry(char *, int, int);
struct node *insert(struct node *);
struct node *lookup(char *);

// Getters
char *get_id(struct node *);
int get_data_type(struct node *);
int get_qualifier_type(struct node *);
float get_float(struct node *);
int get_int(struct node *);
struct node *get_next(struct node *);

// Setters
void set_id(struct node *, char *);
void set_data_type(struct node *, int);
void set_qualifier_type(struct node *, int);
void set_float(struct node *, float);
void set_int(struct node *, int);
void set_next(struct node *, struct node *);

int is_integer(float);